import pandas as pd

configfile: "config/config.yaml"

_samples = pd.read_csv(
    config["samples"], sep="\t", comment="#",
    names=["sample_id", "condition", "replicate", "merge_group"],
).dropna(subset=["sample_id"])
_samples = _samples[_samples["sample_id"].str.strip() != ""]

SAMPLES = _samples["sample_id"].tolist()
SAMPLE_NAMES = [f"{r['merge_group']}_{r['replicate']}" for _, r in _samples.iterrows()]
SAMPLE_TO_NAME = dict(zip(SAMPLES, SAMPLE_NAMES))
NAME_TO_SAMPLE = {v: k for k, v in SAMPLE_TO_NAME.items()}
MERGE_GROUPS = sorted(_samples["merge_group"].unique().tolist())
GROUP_TO_SAMPLES = {
    g: _samples.loc[_samples["merge_group"] == g, "sample_id"].tolist()
    for g in MERGE_GROUPS
}

wildcard_constraints:
    sample="|".join(SAMPLES),
    name="|".join(SAMPLE_NAMES),
    group="|".join(MERGE_GROUPS),
    read="1|2",

include: "workflow/rules/qc.smk"
include: "workflow/rules/trim.smk"
include: "workflow/rules/align.smk"
include: "workflow/rules/normalize.smk"
include: "workflow/rules/downsample.smk"
include: "workflow/rules/bigwig.smk"
include: "workflow/rules/multiqc.smk"

_targets  = expand(f"{config['qc_dir']}/{{sample}}_R{{read}}_001_fastqc.zip",
                   sample=SAMPLES, read=[1, 2])
if config.get("run_fastq_screen", False):
    _targets += expand(f"{config['qc_dir']}/{{sample}}_R{{read}}_001_screen.txt",
                       sample=SAMPLES, read=[1, 2])
_targets += expand(f"{config['bw_dir']}/{{name}}_bs{config['binsize']}.bw",
                   name=SAMPLE_NAMES)
_targets += expand(f"{config['bw_dir']}/{{group}}_merged_bs{config['binsize']}.bw",
                   group=MERGE_GROUPS)
_targets += [
    f"{config['multiqc_dir']}/multiqc_qc_report.html",
    f"{config['multiqc_dir']}/multiqc_final_report.html",
]

rule all:
    input: _targets