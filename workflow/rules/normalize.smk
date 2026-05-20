rule spikein_norm_factors:
    input:
        bams=expand(
            f"{config['align_dir']}/{{sample}}_spikein_Aligned.sortedByCoord.out.bam",
            sample=SAMPLES),
    output: tsv=f"{config['scratch_dir']}/spikein_norm_factors.tsv"
    threads: config["threads"]
    log: "logs/normalize/spikein_norm.log"
    run:
        import os, subprocess
        counts = {}
        for sample, bam in zip(SAMPLES, input.bams):
            n = int(subprocess.check_output(
                ["samtools","view","-@",str(threads),"-c","-q","255",bam]).strip())
            counts[sample] = n
        min_count = min(counts.values())
        os.makedirs(os.path.dirname(output.tsv), exist_ok=True)
        with open(output.tsv, "w") as fh:
            fh.write("sample_id\tspikein_reads\tnorm_factor\n")
            for sample, n in counts.items():
                fh.write(f"{sample}\t{n}\t{min_count/n:.5f}\n")