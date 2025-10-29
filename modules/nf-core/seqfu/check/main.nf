process SEQFU_CHECK {
    tag "$meta.id"
    label 'process_low'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/seqfu:1.22.3--hc29b5fc_1':
        'biocontainers/seqfu:1.22.3--hc29b5fc_1' }"

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("${prefix}.tsv"), emit: check
    path "versions.yml"                   , emit: versions

    when:                                  
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    prefix = task.ext.prefix ?: "${meta.id}"

    def dirFlag = (reads instanceof List ? reads.every { it.isDirectory() } : reads.isDirectory()) ? "--dir" : ""

    """
    seqfu \\
        check \\
        ${args} \\
        ${dirFlag} ${reads} > ${prefix}.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        seqfu: \$(seqfu --version)
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    prefix = task.ext.prefix ?: "${meta.id}"
    """
    echo $args
    
    touch ${prefix}.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        seqfu: \$(seqfu --version)
    END_VERSIONS
    """
}
