rule star_align_hg38:
    input:
        r1=f"{config['trim_dir']}/{{sample}}_clean_R1.fastq.gz",
        r2=f"{config['trim_dir']}/{{sample}}_clean_R2.fastq.gz",
    output:
        bam=f"{config['align_dir']}/{{sample}}_Aligned.sortedByCoord.out.bam",
        bai=f"{config['align_dir']}/{{sample}}_Aligned.sortedByCoord.out.bam.bai",
        log_final=f"{config['align_dir']}/{{sample}}_Log.final.out",
    threads: config["threads"]
    log: "logs/star_hg38/{sample}.log"
    conda: "../envs/tools.yaml"
    params:
        genome=config["genome_dir"],
        prefix=lambda wc: f"{config['align_dir']}/{wc.sample}_",
    shell:
        "STAR --runMode alignReads --runThreadN {threads} "
        "--genomeDir {params.genome} "
        "--readFilesIn {input.r1} {input.r2} --readFilesCommand zcat "
        "--outFileNamePrefix {params.prefix} "
        "--outSAMtype BAM SortedByCoordinate "
        "--outSAMattributes NH HI AS nM MD --genomeLoad NoSharedMemory "
        "--outFilterMultimapNmax 10 --outFilterMismatchNoverReadLmax 0.04 "
        "--alignIntronMax 1000000 --alignMatesGapMax 1000000 "
        "--alignEndsType EndToEnd --outReadsUnmapped Fastx "
        "--quantMode TranscriptomeSAM GeneCounts --twopassMode Basic &> {log} && "
        "samtools index -@ {threads} {output.bam}"

rule star_align_spikein:
    input:
        r1=f"{config['trim_dir']}/{{sample}}_clean_R1.fastq.gz",
        r2=f"{config['trim_dir']}/{{sample}}_clean_R2.fastq.gz",
    output:
        bam=f"{config['align_dir']}/{{sample}}_spikein_Aligned.sortedByCoord.out.bam",
        bai=f"{config['align_dir']}/{{sample}}_spikein_Aligned.sortedByCoord.out.bam.bai",
        log_final=f"{config['align_dir']}/{{sample}}_spikein_Log.final.out",
    threads: config["threads"]
    log: "logs/star_spikein/{sample}.log"
    conda: "../envs/tools.yaml"
    params:
        genome=config["spikein_genome_dir"],
        prefix=lambda wc: f"{config['align_dir']}/{wc.sample}_spikein_",
    shell:
        "STAR --runMode alignReads --runThreadN {threads} "
        "--genomeDir {params.genome} "
        "--readFilesIn {input.r1} {input.r2} --readFilesCommand zcat "
        "--outFileNamePrefix {params.prefix} "
        "--outSAMtype BAM SortedByCoordinate "
        "--outSAMattributes NH HI AS nM MD --genomeLoad NoSharedMemory "
        "--outFilterMultimapNmax 10 --outFilterMismatchNoverReadLmax 0.04 "
        "--alignIntronMax 1000000 --alignMatesGapMax 1000000 "
        "--alignEndsType EndToEnd --outReadsUnmapped Fastx "
        "--quantMode TranscriptomeSAM GeneCounts &> {log} && "
        "samtools index -@ {threads} {output.bam}"