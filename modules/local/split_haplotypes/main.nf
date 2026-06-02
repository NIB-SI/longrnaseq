process SPLIT_HAPLOTYPES {
    tag "$meta.id"
    label 'process_single'
    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/gawk:5.3.0' :
        'biocontainers/gawk:5.3.0' }"

    input:
    tuple val(meta), path(input_gff)

    output:
    tuple val(meta), path("hap*.gff"), emit: split_gffs
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    # Extract unique haplotype labels directly from the sequence names in the first GFF column.
    haplotypes=\$(awk -F'\t' '
        function seq_hap(seqid,   s) {
            s = seqid

            if (s ~ /_[A-Za-z]+\$/) {
                sub(/^.*_/, "", s)
                return toupper(s)
            }

            if (s ~ /[0-9]+[A-Za-z]+\$/) {
                sub(/^.*[0-9]/, "", s)
                return toupper(s)
            }

            if (s ~ /^[A-Za-z]+[0-9]+\$/) {
                sub(/[0-9]+\$/, "", s)
                return toupper(s)
            }

            return ""
        }

        \$0 !~ /^#/ && NF >= 1 {
            hap = seq_hap(\$1)
            if (hap != "") {
                print hap
            }
        }
    ' "$input_gff" | sort -u)

    # If no Chr pattern found, try the original numeric pattern
    if [[ -z "\$haplotypes" ]]; then
        haplotypes=\$(seq 1 $params.ploidy)
    fi

    # Split into haplotype-specific files
    for hap in \$haplotypes; do
        echo \$hap
        awk -F'\t' -v hap="\$hap" '
            function seq_hap(seqid,   s) {
                s = seqid

                if (s ~ /_[A-Za-z]+\$/) {
                    sub(/^.*_/, "", s)
                    return toupper(s)
                }

                if (s ~ /[0-9]+[A-Za-z]+\$/) {
                    sub(/^.*[0-9]/, "", s)
                    return toupper(s)
                }

                if (s ~ /^[A-Za-z]+[0-9]+\$/) {
                    sub(/[0-9]+\$/, "", s)
                    return toupper(s)
                }

                return ""
            }

            \$0 ~ /^#/ {
                print
                next
            }

            seq_hap(\$1) == hap {
                print
            }
        ' "$input_gff" > "hap\${hap}.gff"
    done

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        grep: \$(grep --version | head -n1 | sed 's/.*[[:space:]]\\([0-9][0-9.]*\\).*/\\1/')
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch hap1.gff

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        grep: \$(grep --version | head -n1 | sed 's/.*[[:space:]]\\([0-9][0-9.]*\\).*/\\1/')
    END_VERSIONS
    """
}
