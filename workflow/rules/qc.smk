rule fastqc:
    input:
        fq=lambda wc: f"{config['fastq_dir']}/{config['fastq_pattern'].format(sample=wc.sample, read=wc.read)}"
    output:
        html=f"{config['qc_dir']}/{{sample}}_R{{read}}_001_fastqc.html",
        zip=f"{config['qc_dir']}/{{sample}}_R{{read}}_001_fastqc.zip",
    threads: 4
    log: "logs/fastqc/{sample}_R{read}.log"
    conda: "../envs/tools.yaml"
    params: outdir=config["qc_dir"]
    shell: "fastqc -t {threads} -o {params.outdir} {input.fq} &> {log}"

# rule fastq_screen:
#     input:
#         fq=lambda wc: f"{config['fastq_dir']}/{config['fastq_pattern'].format(sample=wc.sample, read=wc.read)}"
#     output: txt=f"{config['qc_dir']}/{{sample}}_R{{read}}_001_screen.txt"
#     threads: 8
#     log: "logs/fastq_screen/{sample}_R{read}.log"
#     conda: "../envs/too.yaml"
#     params: outdir=config["qc_dir"], conf=config["fastq_screen_conf"]
#     shell:
#         "fastq_screen --aligner BOWTIE2 --threads {threads} "
#         "--conf {params.conf} --outdir {params.outdir} {input.fq} &> {log}"