rule bigwig_individual:
    input:
        bam=lambda wc: f"{config['align_dir']}/{NAME_TO_SAMPLE[wc.name]}_sub_sorted.bam",
        bai=lambda wc: f"{config['align_dir']}/{NAME_TO_SAMPLE[wc.name]}_sub_sorted.bam.bai",
    output: bw=f"{config['bw_dir']}/{{name}}_bs{config['binsize']}.bw"
    threads: config["threads"]
    log: "logs/bigwig/{name}.log"
    conda: "../envs/deeptools.yaml"
    params:
        bs=config["binsize"],
        norm=config["normalize_using"],
        extra=config.get("bamcoverage_extra", ""),
    shell:
        "bamCoverage -b {input.bam} -o {output.bw} -p {threads} "
        "--binSize {params.bs} --normalizeUsing {params.norm} "
        "{params.extra} &> {log}"

rule bigwig_merged:
    input:
        bws=lambda wc: [f"{config['bw_dir']}/{SAMPLE_TO_NAME[s]}_bs{config['binsize']}.bw"
                        for s in GROUP_TO_SAMPLES[wc.group]],
    output: bw=f"{config['bw_dir']}/{{group}}_merged_bs{config['binsize']}.bw"
    threads: config["threads"]
    log: "logs/bigwig_merged/{group}.log"
    conda: "../envs/deeptools.yaml"
    params: bs=config["binsize"]
    shell:
        "bigwigAverage -b {input.bws} -o {output.bw} -p {threads} "
        "--binSize {params.bs} &> {log}"
