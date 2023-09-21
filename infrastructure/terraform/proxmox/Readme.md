# GVT-G howto

This only works until Intel gen 10, later generations use IO-SRV virtualization

### Figure out how much memory you have assigned to the igp

```
lspci -v -s 00:02.0

00:02.0 VGA compatible controller: Intel Corporation HD Graphics 530 (rev 06) (prog-if 00 [VGA controller])
        Subsystem: Dell HD Graphics 530
        Flags: bus master, fast devsel, latency 0, IRQ 169, IOMMU group 0
        Memory at 2ffe000000 (64-bit, non-prefetchable) [size=16M]
        Memory at 2f00000000 (64-bit, prefetchable) [size=2G]
        I/O ports at f000 [size=64]
        Expansion ROM at 000c0000 [virtual] [disabled] [size=128K]
        Capabilities: [40] Vendor Specific Information: Len=0c <?>
        Capabilities: [70] Express Root Complex Integrated Endpoint, MSI 00
        Capabilities: [ac] MSI: Enable+ Count=1/1 Maskable- 64bit-
        Capabilities: [d0] Power Management version 2
        Capabilities: [100] Process Address Space ID (PASID)
        Capabilities: [200] Address Translation Service (ATS)
        Capabilities: [300] Page Request Interface (PRI)
        Kernel driver in use: i915
        Kernel modules: i915
```

You need at least 256M to create at least the smallest variant. If you don't have that much, or want more, you need to change your Aperture Size in BIOS/Firmware
