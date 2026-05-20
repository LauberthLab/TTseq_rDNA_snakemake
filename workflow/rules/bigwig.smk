rule bigwig_individual:
    input:
        bam=lambda wc: f"{config['align_dir']}/{NAME_TO_SAMPLE[wc.name]}_sub_sorted.bam",
        bai=lambda wc: f"{config['align_dir']}/{NAME_TO_SAMPLE[wc.name]}_sub_sorted.bam.bai",
    output: bw=f"{config['bw_dir']}/{{name}}_bs{config['binsize']}.bw"
    threads: config["threads"]
    log: "logs/bigwig/{name}.log"
    conda: "../envs/deeptools.yaml"
    params: bs=config["binsize"], norm=config["normalize_using"]
    shell:
        "bamCoverage -b {input.bam} -o {output.bw} -p {threads} "
        "--normalizeUsing {params.norm} --binSize {params.bs} &> {log}"

rule merge_bams:
    input:
        bams=lambda wc: [f"{config['align_dir']}/{s}_sub_sorted.bam"
                         for s in GROUP_TO_SAMPLES[wc.group]],
    output:
        bam=f"{config['align_dir']}/{{group}}_merged.bam",
        bai=f"{config['align_dir']}/{{group}}_merged.bam.bai",
    threads: config["threads"]
    log: "logs/merge/{group}.log"
    conda: "../envs/deeptools.yaml"
    shell:
        "samtools merge -f -@ {threads} {output.bam} {input.bams} 2> {log} && "
        "samtools index -@ {threads} {output.bam}"

rule bigwig_merged:
    input:
        bam=f"{config['align_dir']}/{{group}}_merged.bam",
        bai=f"{config['align_dir']}/{{group}}_merged.bam.bai",
    output: bw=f"{config['bw_dir']}/{{group}}_merged_bs{config['binsize']}.bw"
    threads: config["threads"]
    log: "logs/bigwig_merged/{group}.log"
    conda: "../envs/deeptools.yaml"
    params: bs=config["binsize"], norm=config["normalize_using"]
    shell:
        "bamCoverage -b {input.bam} -o {output.bw} -p {threads} "
        "--normalizeUsing {params.norm} --binSize {params.bs} &> {log}"