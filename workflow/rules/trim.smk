rule fastp_trim:
    input:
        r1=lambda wc: f"{config['fastq_dir']}/{config['fastq_pattern'].format(sample=wc.sample, read=1)}",
        r2=lambda wc: f"{config['fastq_dir']}/{config['fastq_pattern'].format(sample=wc.sample, read=2)}",
    output:
        r1=f"{config['trim_dir']}/{{sample}}_clean_R1.fastq.gz",
        r2=f"{config['trim_dir']}/{{sample}}_clean_R2.fastq.gz",
        html=f"{config['trim_dir']}/{{sample}}_fastp_report.html",
        json=f"{config['trim_dir']}/{{sample}}_fastp_report.json",
    threads: 12
    log: "logs/fastp/{sample}.log"
    conda: "../envs/tools.yaml"
    shell:
        "fastp --in1 {input.r1} --in2 {input.r2} "
        "--out1 {output.r1} --out2 {output.r2} "
        "--thread {threads} --detect_adapter_for_pe "
        "--html {output.html} --json {output.json} &> {log}"