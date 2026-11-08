#!/usr/bin/env python3
"""Temporary manual benchmark; never invokes Compose or Doco-CD."""
import json
import pathlib
import subprocess
import time


ROOT = pathlib.Path(__file__).resolve().parents[3]
BASE = 'http://127.0.0.1:18080'
IMAGE = 'ghcr.io/ggml-org/llama.cpp:server-b9570@sha256:4c52f549b6612fc1b4aee696c4cfb4a9dceecb10216bb7e677cf97db909e1b4a'
CACHE = '/mnt/SSD/docker-applications/qwen-bench/cache'
GEMMA = '/root/.cache/llama.cpp/models--unsloth--gemma-4-26B-A4B-it-GGUF/snapshots/c099eb48e663fd284577b04978a94ffccb261841/gemma-4-26B-A4B-it-UD-Q4_K_M.gguf'


def ssh(*args):
    return subprocess.run(['ssh', '-o', 'BatchMode=yes', '-o', 'ConnectTimeout=10', 'leo.ishioni.casa', *args], check=True, text=True, capture_output=True).stdout.strip()


def http(path, body=None, timeout=300):
    code = ('import json,sys,urllib.request; '
            'data=sys.stdin.buffer.read(); '
            'req=urllib.request.Request("' + BASE + path + '", '
            'data=data if data else None, headers={"Content-Type":"application/json"}); '
            'print(urllib.request.urlopen(req,timeout=' + str(timeout) + ').read().decode())')
    result = subprocess.run(['ssh', '-o', 'BatchMode=yes', '-o', 'ConnectTimeout=10',
                             'leo.ishioni.casa', "python3 -c '" + code + "'"],
                            input=json.dumps(body).encode() if body else b'', capture_output=True,
                            timeout=timeout + 20, check=True)
    return json.loads(result.stdout)


def ready():
    for _ in range(90):
        try:
            if http('/health', timeout=4).get('status') == 'ok':
                return
        except (OSError, subprocess.CalledProcessError, subprocess.TimeoutExpired):
            pass
        time.sleep(3)
    raise TimeoutError('model not ready within 270 seconds')


def context(paths):
    return '\n\n'.join(f'### {p}\n```\n{(ROOT / p).read_text()}\n```' for p in paths)


PROMPTS = {
    'yaml': '''You are reviewing a proposed TrueNAS Compose service in this repo. Read the attached real configuration carefully; don't assume a public reverse proxy or that Doco-CD is safe to trigger during the trial. Draft a minimal NEW docker-compose.yml for a private, CPU-only OpenAI-compatible model service: internal Traefik HTTPS hostname qwen.ishioni.casa, dexd DNS, apps network, no host-published port, 24 GiB memory ceiling, four CPU threads, one parallel slot, 16K context, persistent cache, and restrict HTTP via Traefik to 10.1.0.0/16. Use image and model parameters from the provided qwen stack. Give the full YAML and a short checklist of correctness/security traps and how to validate without deploying. Do not invent credentials or create a new network. Cite file paths when explaining decisions. Be concise: no preamble, no headings, give YAML first and at most four short checklist bullets.\n\n'''+context(['docker/truenas/.doco-cd.yaml', 'docker/truenas/01-traefik/docker-compose.yml', 'docker/truenas/03-rustfs/docker-compose.yml', 'docker/truenas/05-scrutiny/docker-compose.yml', 'docker/truenas/07-qwen/docker-compose.yml']),
    'tofu': '''Review these real OpenTofu module and caller files. I want an additional private RustFS bucket named 'infra-state' with versioning enabled and a dedicated user whose secret comes from the Homelab 1Password vault using the existing module style. Give the minimum caller HCL (no secret value), the exact module behavior that makes this safe or unsafe (including current default ACL, versioning and user creation, relevant provider resources/lifecycle), and a safe validation plan that does not actually apply infrastructure. Avoid inventing provider-specific features not shown; flag what you cannot prove from the files. Cite the file paths used. Be concise: caller HCL first, followed by at most six short bullets for behavior, risks and validation; no headings or preamble.\n\n'''+context(['terraform/rustfs/modules/rustfs/main.tofu', 'terraform/rustfs/modules/rustfs/variables.tofu', 'terraform/rustfs/modules/rustfs/outputs.tofu', 'terraform/rustfs/dragonfly.tofu', 'terraform/rustfs/kopiur.tofu', 'terraform/rustfs/main.tofu', 'terraform/rustfs/talos.tofu']),
}


def run_model(label, name):
    ready()
    for task, prompt in PROMPTS.items():
        payload = {'model': name, 'messages': [{'role': 'user', 'content': prompt}], 'temperature': 0, 'max_tokens': 1000, 'seed': 42, 'chat_template_kwargs': {'enable_thinking': False}}
        start = time.monotonic()
        response = http('/v1/chat/completions', payload)
        elapsed = time.monotonic() - start
        output = response['choices'][0]['message'].get('content') or ''
        print(json.dumps({'model': label, 'task': task, 'input_chars': len(prompt), 'elapsed_s': round(elapsed, 2), 'usage': response.get('usage'), 'timings': response.get('timings'), 'finish_reason': response['choices'][0]['finish_reason'], 'output': output}), flush=True)


def main():
    gemma_started = False
    qwen_stopped = False
    try:
        run_model('qwen3-coder-30b-a3b-q4_k_m', 'qwen3-coder-30b-a3b-q4-k-m')
        ssh('docker', 'stop', 'qwen-bench-coder-final')
        qwen_stopped = True
        ssh('docker', 'run', '-d', '--name', 'gemma-bench-long', '--memory', '28g', '--memory-swap', '28g', '--cpus', '4', '--publish', '127.0.0.1:18080:8080', '-v', CACHE + ':/root/.cache', '-e', 'LLAMA_CACHE=/root/.cache/llama.cpp', IMAGE, '-m', GEMMA, '--alias', 'gemma-4-26b-a4b-q4-k-m', '--host', '0.0.0.0', '--port', '8080', '--ctx-size', '16384', '--threads', '4', '--threads-batch', '4', '--parallel', '1', '--cache-ram', '512', '--jinja', '--no-ui', '--poll', '0')
        gemma_started = True
        run_model('gemma-4-26b-a4b-unsloth-q4_k_m', 'gemma-4-26b-a4b-q4-k-m')
    finally:
        if gemma_started:
            ssh('docker', 'rm', '-f', 'gemma-bench-long')
        if qwen_stopped:
            ssh('docker', 'start', 'qwen-bench-coder-final')

        print('RESTORED_QWEN; check health after loading', flush=True)


if __name__ == '__main__':
    main()
