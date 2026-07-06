process OARFISH {
    tag "$meta.id"
    label 'process_single'

    cache 'lenient'

    // TODO nf-core: List required Conda package(s).
    //               Software MUST be pinned to channel (i.e. "bioconda"), version (i.e. "1.10").
    //               For Conda, the build (i.e. "h9402c20_2") must be EXCLUDED to support installation on different operating systems.
    // TODO nf-core: See section in main README for further information regarding finding and adding container addresses to the section below.
    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'community.wave.seqera.io/library/oarfish:0.10.0--6e68b4d7cecaf8da':
        'biocontainers/oarfish:0.10.0--hd727d2a_0' }"


    input:
    tuple val(meta), path(bam)

    output:
    tuple val(meta), path("${prefix}")        , emit: results
    tuple val(meta), path("${meta.id}.ambig_info.tsv")        , emit: ambig_info
    tuple val(meta), path("*.meta_info.json")  , emit: json_info
    tuple val(meta), path(".command.log")            , emit: log
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    prefix = task.ext.prefix ?: "${meta.id}"

    """
    mkdir $prefix && oarfish $args \\
            -j $task.cpus \\
            --alignments $bam \\
            -o $prefix \\
            --filter-group no-filters \\
            --write-assignment-probs \\
            --score-threshold 1.0

    # Add the transcript ids to the ambig_info.tsv file
    paste <(awk '{print \$1}' "${meta.id}.quant") \\
      <(awk '{print \$1 "\\t" \$2}' "${meta.id}.ambig_info.tsv") \\
      > "${meta.id}.ambig_info.tmp" && \\
    mv "${meta.id}.ambig_info.tmp" "${meta.id}.ambig_info.tsv"

    # Rename .qant file to qant.sf to match salmon output
    mv ${prefix}.quant ${prefix}/quant.sf

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        oarfish: \$(oarfish --version |& sed '1!d ; s/oarfish //')
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    prefix = task.ext.prefix ?: "${meta.id}"

    """
    mkdir -p $prefix
    touch ${prefix}.log
    touch ${prefix}.meta_info.json
    touch ${prefix}.ambig_info.json


    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        oarfish: \$(oarfish --version |& sed '1!d ; s/oarfish //')
    END_VERSIONS
    """
}
