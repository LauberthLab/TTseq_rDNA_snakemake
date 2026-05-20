# TT-seq at rDNA Snakemake Workflow

Spike-in normalized TT-seq pipeline for mapping nascent transcription across the human rDNA locus. Built with Snakemake, with one conda env per tool.

## Steps

| # | Step | Tool |
|---|------|------|
| 0 | FastQC (+ optional FastQ-Screen) | fastqc / fastq-screen |
| 1 | Adapter trimming | fastp |
| 2 | Align to hg38+rDNA | STAR |
| 3 | Align to dm6 spike-in | STAR |
| 4 | Spike-in normalization factors | samtools |
| 5 | Downsample BAMs | samtools |
| 6 | Per-replicate bigWigs | deeptools |
| 7 | Merged-per-condition bigWigs | samtools + deeptools |
| 8 | MultiQC aggregation | multiqc |

## Layout
.
├── Snakefile
├── config/
│ ├── config.yaml # paths, params, FASTQ pattern
│ └── samples.tsv # sample_id condition replicate merge_group
├── profiles/slurm/
│ └── config.yaml # SLURM submission profile
├── workflow/
│ ├── envs/ # one conda env yaml per tool
│ └── rules/ # qc, trim, align, normalize, downsample, bigwig, multiqc
├── results/ # outputs (BAMs, bigWigs, QC, MultiQC)
└── logs/ # per-rule logs

## Quick start
1. Edit `config/samples.tsv` with your samples.
2. Set paths in `config/config.yaml` (FASTQ dir, STAR indices, FASTQ pattern).
3. Run:
```bash
# local
snakemake --use-conda --cores 40
# dry-run
snakemake --use-conda -n
# SLURM
snakemake --use-conda --profile profiles/slurm
Sample sheet
config/samples.tsv — tab-separated, 4 columns:

#sample_id              condition  replicate  merge_group
21161R-97-01_S96_L002   DMSO       rep1       TT_DMSO
21161R-97-04_S99_L002   TPT        rep1       TT_TPT
Samples sharing a merge_group are pooled in step 7. FASTQs are expected as {sample_id}_R{1,2}_001.fastq.gz in fastq_dir (override via fastq_pattern in config.yaml).

Outputs
results/
├── QC/                              # FastQC (+ FastQ-Screen)
├── FASTQ_TRIM/{sample}_clean_R{1,2}.fastq.gz
├── BAMS/
│   ├── {sample}_Aligned.sortedByCoord.out.bam
│   ├── {sample}_spikein_Aligned.sortedByCoord.out.bam
│   ├── {sample}_sub_sorted.bam              # downsampled
│   └── {merge_group}_merged.bam
├── BIGWIGS/
│   ├── {merge_group}_{rep}_bs1.bw
│   └── {merge_group}_merged_bs1.bw
└── MULTIQC/{multiqc_qc_report,multiqc_final_report}.html
spikein_norm_factors.tsv (under scratch_dir) holds the per-sample normalization fractions.

References
rDNA mapping genome: https://github.com/vikramparalkar/rDNA-Mapping-Genomes
Schwalb et al., Science 352, 1225 (2016) — TT-seq
Dobin et al., Bioinformatics 29, 15 (2013) — STAR
Ramírez et al., NAR 44, W160 (2016) — deepTools