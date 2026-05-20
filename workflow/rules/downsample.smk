rule downsample:
    input:
        bam=f"{config['align_dir']}/{{sample}}_Aligned.sortedByCoord.out.bam",
        norm=f"{config['scratch_dir']}/spikein_norm_factors.tsv",
    output:
        bam=f"{config['align_dir']}/{{sample}}_sub_sorted.bam",
        bai=f"{config['align_dir']}/{{sample}}_sub_sorted.bam.bai",
    threads: config["threads"]
    log: "logs/downsample/{sample}.log"
    conda: "../envs/tools.yaml"
    params: seed=config["rand_seed"]
    shell:
        r"""
        frac=$(awk -F'\t' -v s={wildcards.sample} '!/^#/ && $1==s {{print $3}}' {input.norm})
        [ -z "$frac" ] && {{ echo "no norm factor for {wildcards.sample}" >&2; exit 1; }}
        skip=$(awk "BEGIN {{print (${{frac}} >= 0.99999) ? 1 : 0}}")
        if [ "$skip" -eq 1 ]; then
            cp {input.bam} {output.bam}
        else
            tmp={output.bam}.tmp.bam
            samtools view -b -@ {threads} -o $tmp -s {params.seed}.${{frac#0.}} {input.bam} 2> {log}
            samtools sort -@ {threads} -o {output.bam} $tmp 2>> {log}
            rm -f $tmp
        fi
        samtools index -@ {threads} {output.bam}
        """