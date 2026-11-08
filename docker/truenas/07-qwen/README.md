# Qwen on Leo (reviewable GitOps configuration)

**Do not merge until the manual trial has been reviewed.** Doco-CD auto-discovers this stack from `docker/truenas/.doco-cd.yaml` on `master`; a draft PR does not deploy it. On merge, dexd registers `qwen.ishioni.casa` in UniFi DNS, and Traefik routes `https://qwen.ishioni.casa/v1` on the existing `apps` network. The `ishioni.casa` / `*.ishioni.casa` Let's Encrypt certificate is configured in `01-traefik/config/traefik.yml`. No host port is published by the GitOps stack.

The router accepts only source addresses in `10.1.0.0/16` (Leo's observed LAN is `10.1.2.0/24`). This is **network restriction, not authentication**. Other trusted containers on `apps` can connect directly. Do not publish or forward this API to the internet or put it behind a public proxy. Check the client IP Traefik sees before adding a specific VPN/VLAN range; never remove the restriction for convenience.

## Manual trial (outside Doco-CD)

The temporary `qwen-bench-coder-final` container on Leo is bound only to `127.0.0.1:18080`. Its model cache is `/mnt/SSD/docker-applications/qwen-bench/cache`, separate from the GitOps cache. To try it on your workstation, open an SSH tunnel with `ssh -L 18080:127.0.0.1:18080 leo.ishioni.casa`, and set an OpenAI-compatible client's base URL to `http://127.0.0.1:18080/v1`, model `qwen3-coder-30b-a3b-q4-k-m`. The loopback endpoint has **no authentication**: do not bind the tunnel to an external address. No persistent TrueNAS ZFS/power settings or Doco-CD configurations were changed for the trial; temporary CPU EPP and GPU DPM changes were restored.

## Architecture and measurements

- A pinned CPU-only `llama.cpp` image serves [Qwen3-Coder-30B-A3B-Instruct Q4_K_M](https://huggingface.co/unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF/blob/main/Qwen3-Coder-30B-A3B-Instruct-Q4_K_M.gguf) (18.6 GB on disk). The **3B active** parameters do not reduce the ~17 GiB of model weights that must fit in RAM. Four CPU threads and a 16K context leave resources for HAOS and other services. The 24 GiB container limit is a ceiling, not a reservation or a substitute for checking host memory. One slot and a 512 MiB prompt cache bound concurrency/caching. After 300 seconds idle the model unloads; the next request incurs a cold-load delay.
- Vulkan **was tested**, not dismissed: `llama-server --list-devices` identified the Vega iGPU as RADV RENOIR using only `/dev/dri/renderD128`. The table below uses the _same short ARC question_, four CPU threads, a four-CPU container limit, 8K context and temperature zero. Rates come from each server's response timings, not a general benchmark; the outputs were often factually wrong.

  | Model / backend                     | Prompt tokens/s | Generated tokens/s | Observed memory                                            |
  | ----------------------------------- | --------------: | -----------------: | ---------------------------------------------------------- |
  | Qwen3-8B Q5_K_M / Vulkan            |              52 |                7.2 | ~5.6 GiB in `docker stats`                                 |
  | Qwen3-8B Q5_K_M / CPU               |              17 |                7.7 | ~1.2 GiB in `docker stats` (mmap/cache accounting differs) |
  | Qwen3-14B Q4_K_M / Vulkan           |              30 |                5.1 | ~9.6 GiB iGPU GTT, **not** captured by `docker stats`      |
  | Qwen3-Coder-30B-A3B Q4_K_M / Vulkan |              21 |               18.5 | ~18 GiB iGPU GTT, **not** captured by `docker stats`       |
  | Qwen3-Coder-30B-A3B Q4_K_M / CPU    |              52 |               19.8 | ~14–19 GiB in `docker stats` (file cache varies)           |

- CPU is the measured winner **for this model and prompt**: no iGPU allocation, faster prompt processing and slightly faster generation. A six-thread run gained little generation speed (~20.3 tokens/s) while occupying more CPU. The CPU-only image was separately tested at 16K context (~19.4 generated tokens/s on a short Compose prompt); no device mapping is needed. After a 20-second experimental idle timeout, reported container memory dropped to ~120 MiB; a subsequent request took ~7 seconds including reload. The GitOps timeout is a less aggressive five minutes.
- The NAS startup script sets CPU `energy_performance_preference=power` and GPU `power_dpm_force_performance_level=auto`; the first table was measured under those settings. A reversible A/B test of the 30B coder model (same prompt, four threads, 16K context, two runs per profile) found **CPU EPP `power` vs `performance`** essentially unchanged: ~19.6–20.0 vs ~19.7–19.9 generated tokens/s. With CPU EPP at `power`, **GPU DPM `auto` vs `high`** likewise yielded ~19.0–19.1 vs ~19.0 tokens/s; under `auto` the iGPU already spent nearly the whole inference at its top reported 1900 MHz clock. Package energy-counter readings overlapped within run-to-run variation; these were not wall-power measurements. Both settings were restored to `power` / `auto`. No evidence here supports weakening the power-saving policy to speed up this model.
- The Vega iGPU shares host RAM. Its advertised ~32 GiB Vulkan heap is **not additional RAM** and its GTT allocations were not reliably counted by `docker stats`; during the 30B Vulkan trial ZFS ARC reclaimed from ~32 GiB to ~15 GiB and host `MemAvailable` recovered to ~18 GiB. That trial used the original 4 GiB minimum / 32 GiB maximum ARC limits; the maximum was subsequently lowered to 16 GiB on Leo for the Gemma full-offload retest below. Keep checking `free -h`, `/proc/spl/kstat/zfs/arcstats`, container memory, and HAOS behavior if workloads grow.

### Gemma 4 comparison (manual trial)

Gemma 4 26B-A4B was also tried with thinking disabled (`chat_template_kwargs: {"enable_thinking": false}`) for comparable short-request timing. These are response timing samples, **not coding-quality scores**. The Google QAT CPU/Vulkan comparison uses the same GGUF; the CPU results across Google QAT Q4_0 and Unsloth Q4_K_M use different quantizations and cannot isolate quantization or conversion effects.

| GGUF / backend                                                                           | Prompt tokens/s | Generated tokens/s | Observed memory                                        |
| ---------------------------------------------------------------------------------------- | --------------: | -----------------: | ------------------------------------------------------ |
| [Google QAT Q4_0](https://huggingface.co/google/gemma-4-26B-A4B-it-qat-q4_0-gguf) / CPU  |             ~47 |              ~15.1 | ~16.2 GiB Docker                                       |
| Google QAT Q4_0 / Vulkan                                                                 |             ~27 |              ~14.2 | ~14.4 GiB iGPU GTT, outside reliable Docker accounting |
| [Unsloth Q4_K_M](https://huggingface.co/unsloth/gemma-4-26B-A4B-it-GGUF/tree/main) / CPU |             ~39 |              ~10.7 | ~24.6 GiB Docker                                       |

Both conversions produced valid OpenAI-format tool calls; Google QAT also completed a tool-result round trip. In one ungrounded ARC question Google QAT returned the malformed byte value `257698131math` on CPU and Vulkan, while Unsloth returned `25769803776`; one answer cannot establish relative coding quality. During the Vulkan trial host `MemAvailable` fell to ~5.9 GiB: shared-memory GTT is not safely bounded by the Docker memory limit. For now Qwen3-Coder remains the faster, lower-memory **provisional** choice (~19–20 generated tokens/s on CPU). Testing representative infrastructure tasks with the intended agent client matters more than this single prompt.

### Longer repository-grounded YAML / OpenTofu comparison

A follow-up manual CPU-only trial compared the retained Qwen3-Coder Q4_K_M and **Unsloth** Gemma 4 26B-A4B Q4_K_M using the same `llama.cpp` b9570 image, four CPU threads/CPU quota, 16K context, one slot, temperature 0, seed 42, thinking disabled, and a 1,000-token output cap. The two prompts supplied real repository files (7.7K characters of TrueNAS Compose/Doco-CD context or 5.4K characters of RustFS OpenTofu module/caller context). Tests ran sequentially via loopback on Leo, not Doco-CD; Qwen's container limit was 24 GiB and Gemma's was 28 GiB. These are **one run per model/task**, not statistically robust or a blinded quality evaluation. Different chat tokenizers mean equal source text yielded different prompt token counts; wall times also include transport, queuing and load overhead.

| Task                   | Model         | Prompt tokens | Prompt tok/s | Generated tokens | Generation tok/s | Wall time |
| ---------------------- | ------------- | ------------: | -----------: | ---------------: | ---------------: | --------: |
| Compose YAML draft     | Qwen3-Coder   |         2,534 |         44.6 |              694 |              9.7 |     129 s |
| Compose YAML draft     | Gemma Unsloth |         2,924 |         36.9 |              794 |              8.3 |     175 s |
| RustFS OpenTofu review | Qwen3-Coder   |         1,510 |         49.1 |              251 |             12.6 |      51 s |
| RustFS OpenTofu review | Gemma Unsloth |         1,803 |         39.1 |              426 |              8.6 |      96 s |

- **Compose:** Both produced plausible internal-network, TLS-router, LAN-allowlist YAML with no published host port. Qwen reproduced more of the existing stack's settings (batch threads, cache limit, dexd hostname). Neither warned that the Traefik allowlist does **not** protect direct requests from other containers on `apps`; Gemma incorrectly linked `dexd.enabled` to Doco-CD auto-discovery. Do not deploy generated YAML without `docker compose config`, a label/network review and an access test.
- **OpenTofu:** Both used the existing module with `versioning = true` and no literal secret. Gemma identified the existing `force_destroy = true` user setting; Qwen missed it and characterized a bucket-scoped `s3:*` policy as full S3 access. Both understated secret/state risks: `sensitive()` does not encrypt state; Gemma recommended `tofu show -json` on a saved plan without warning that plan files/JSON may reveal secrets. Review plan artifacts and the referenced 1Password item before any apply.
- Both models completed these more focused prompts without truncation. Their longer-answer generation rates were **lower than the earlier ~19–20 tokens/s short-prompt Qwen sample**; do not use that short-prompt number as a latency forecast for this workload. The previous 600-token-cap exploratory pass truncated all four answers and is not used for the quality comparison.

The retained **Unsloth** Gemma GGUF was then tried on the same two prompts with the pinned b9570 Vulkan image, `/dev/dri/renderD128`, 16K context, four CPU threads/quota, and 28 GiB Docker limit. Full offload (`--n-gpu-layers 99`) was **stopped by a safety watchdog during the first prompt** when host `MemAvailable` dropped below 8 GiB (iGPU GTT ~16.9 GiB); it returned no answer. At **16 offloaded layers**, both prompts completed:

| Task                   | Prompt tok/s | Generated tokens | Generation tok/s | Wall time |
| ---------------------- | -----------: | ---------------: | ---------------: | --------: |
| Compose YAML draft     |         71.6 |              823 |              9.4 |     129 s |
| RustFS OpenTofu review |         79.2 |              417 |              9.6 |      67 s |

The 16-layer run reached ~9.6 GiB iGPU GTT and a minimum observed host `MemAvailable` of ~9.5 GiB, with no container OOM. GTT is shared host RAM and is not reliably bounded by Docker memory accounting. Compared with Gemma CPU on these prompts, partial Vulkan roughly doubled prompt processing but barely improved generation (~8.3–8.6 to ~9.4–9.6 tokens/s); it matched Qwen's YAML wall time and remained slower on OpenTofu, with less host-memory headroom. Output lengths and answers differed, so these single-run wall times are not a controlled quality comparison. One Vulkan OpenTofu answer incorrectly called `force_destroy = true` safe: continue to require review. CPU EPP `power` and GPU DPM `auto` were unchanged; the manual Qwen container was restored, and no Doco-CD stack was touched.

**ARC-cap retest:** Leo's ZFS ARC was ~25 GiB before the change. Reducing the live `zfs_arc_max` from 32 GiB (`34359738368`) to **16 GiB (`17179869184`)** let ARC settle near 16 GiB, raising idle host `MemAvailable` from ~25–26 to ~34 GiB. The same full-offload Gemma Vulkan configuration (`--n-gpu-layers 99`) then completed both longer prompts, with the 8 GiB watchdog still in place:

| Task                   | Prompt tok/s | Generated tokens | Generation tok/s | Wall time |
| ---------------------- | -----------: | ---------------: | ---------------: | --------: |
| Compose YAML draft     |         95.1 |              793 |              9.7 |     113 s |
| RustFS OpenTofu review |         95.3 |              389 |              9.8 |      59 s |

The lowest sampled host `MemAvailable` was ~16.4 GiB, peak GTT ~16.9 GiB and lowest sampled ARC ~15.9 GiB; no container OOM. This **supports ARC as a major contributor to the earlier memory pressure**, but does not prove ARC was the only cause. To compare under the **same new ARC cap**, both CPU models were rerun on the same prompts:

| Task                   | CPU model     | Prompt tok/s | Generated tokens | Generation tok/s | Wall time |
| ---------------------- | ------------- | -----------: | ---------------: | ---------------: | --------: |
| Compose YAML draft     | Qwen3-Coder   |         42.9 |              694 |              9.6 |     132 s |
| Compose YAML draft     | Gemma Unsloth |         38.1 |              794 |              8.6 |     170 s |
| RustFS OpenTofu review | Qwen3-Coder   |         48.3 |              251 |             12.6 |      52 s |
| RustFS OpenTofu review | Gemma Unsloth |         38.3 |              426 |              8.7 |      97 s |

During the CPU Gemma rerun the lowest sampled host `MemAvailable` was ~24.7 GiB (ARC ~16 GiB); no container OOM. Lowering the ARC cap did not materially alter CPU rates compared with the earlier table. Full Vulkan improves Gemma prompt processing substantially while generation stays near 10 tokens/s; it beat Qwen CPU on YAML wall time (113 vs 132 s) but not OpenTofu (59 vs 52 s), with **different output lengths**. These are single-run measurements, not a general performance or quality verdict. The 16 GiB maximum was also saved as TrueNAS ZFS tunable ID 21 for startup; `zfs_arc_min` remains 4 GiB. This out-of-band NAS setting may reduce ZFS cache hit rates under other workloads: monitor ARC misses, disk I/O, HAOS and host headroom, and restore `34359738368` in the TrueNAS tunable and live `/sys/module/zfs/parameters/zfs_arc_max` if needed. Neither the trial nor the tunable change involved Doco-CD.

**Important limitation:** All three Qwen variants gave incorrect or dangerously imprecise answers to a TrueNAS ARC modification question, including wrong commands or wrong byte values. The coder model also invented obsolete image names and paths in a Compose drafting exercise. Treat it as a **supervised coding assistant, not an autonomous infrastructure operator**. Have it read real documentation/current configuration via reviewed, initially read-only MCP tools; validate generated YAML and commands and require human approval for changes. Tool-call parsing and a follow-up tool-result response worked in the manual trial when the client sent the same tool definitions on both requests; test your actual MCP agent client before enabling write-capable tools.

MCP tools belong in the agent client, not the NAS inference server. Point its OpenAI-compatible model provider at `https://qwen.ishioni.casa/v1` _after_ GitOps deployment and use model `qwen3-coder-30b-a3b-q4-k-m`. The model server gets no shell, filesystem, Docker socket or MCP credentials. If a client insists on an API key, a dummy value is enough for this unauthenticated endpoint; that is **not security**.

## Before merging

1. Review the 24 GiB maximum, LAN CIDR and access policy. The manual cache currently holds the coder model (~18 GiB) and Unsloth Gemma (~16 GiB), ~34 GiB in total; the Google QAT download was removed. GitOps still points at the **existing** `/mnt/SSD/docker-applications/llamacpp/cache`; either copy the coder model snapshot to that cache without deleting existing data, or accept another ~18.6 GB Hugging Face download on first deployment. Do not delete the temporary cache until the GitOps service has successfully loaded the model.
2. Stop/remove the loopback-only manual container before the GitOps service starts, so the two do not compete for RAM. Then verify Doco-CD picked up the stack, dexd/DNS resolves to internal Traefik, the TLS certificate is trusted, `/health` and `/v1/models` respond from an allowed client, and a disallowed client receives 403. Watch host and HAOS memory while testing real prompts and a full MCP tool round trip.
3. Only after verifying the replacement, clean up the temporary cache and images if desired. Merge into `master` **will** trigger Doco-CD deployment during reconciliation; the manual trial does not involve Doco-CD.
