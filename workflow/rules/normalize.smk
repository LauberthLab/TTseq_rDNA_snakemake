rule spikein_count:
    input: bam=f"{config['align_dir']}/{{sample}}_spikein_Aligned.sortedByCoord.out.bam"
    output: f"{config['scratch_dir']}/spikein_counts/{{sample}}.txt"
    threads: config["threads"]
    log: "logs/normalize/spikein_count_{sample}.log"
    conda: "../envs/tools.yaml"
    shell: "samtools view -@ {threads} -c -q 255 {input.bam} > {output} 2> {log}"

rule spikein_norm_factors:
    input: expand(f"{config['scratch_dir']}/spikein_counts/{{sample}}.txt", sample=SAMPLES)
    output: tsv=f"{config['scratch_dir']}/spikein_norm_factors.tsv"
    run:
        counts = {s: int(open(f).read().strip()) for s, f in zip(SAMPLES, input)}
        min_count = min(counts.values())
        with open(output.tsv, "w") as fh:
            fh.write("sample_id\tspikein_reads\tnorm_factor\n")
            for s, n in counts.items():
                fh.write(f"{s}\t{n}\t{min_count/n:.5f}\n")
