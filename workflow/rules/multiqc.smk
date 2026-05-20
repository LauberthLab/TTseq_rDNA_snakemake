rule multiqc_qc:
    input:
        expand(f"{config['qc_dir']}/{{sample}}_R{{read}}_001_fastqc.zip",
               sample=SAMPLES, read=[1, 2]),
        expand(f"{config['trim_dir']}/{{sample}}_fastp_report.json", sample=SAMPLES),
    output: html=f"{config['multiqc_dir']}/multiqc_qc_report.html"
    log: "logs/multiqc/qc.log"
    conda: "../envs/multiqc.yaml"
    params: qc_dir=config["qc_dir"], trim_dir=config["trim_dir"], out=config["multiqc_dir"]
    shell:
        "multiqc {params.qc_dir} {params.trim_dir} -o {params.out} "
        "-n multiqc_qc_report --force &> {log}"

rule multiqc_final:
    input:
        bws=expand(f"{config['bw_dir']}/{{name}}_bs{config['binsize']}.bw", name=SAMPLE_NAMES),
        merged=expand(f"{config['bw_dir']}/{{group}}_merged_bs{config['binsize']}.bw", group=MERGE_GROUPS),
    output: html=f"{config['multiqc_dir']}/multiqc_final_report.html"
    log: "logs/multiqc/final.log"
    conda: "../envs/multiqc.yaml"
    params:
        qc_dir=config["qc_dir"], trim_dir=config["trim_dir"],
        align_dir=config["align_dir"], out=config["multiqc_dir"],
    shell:
        "multiqc {params.qc_dir} {params.trim_dir} {params.align_dir} "
        "-o {params.out} -n multiqc_final_report --force &> {log}"