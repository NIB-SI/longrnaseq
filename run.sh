

conda activate nextflow

nextflow run main.nf -profile singularity -with-report report.html -with-trace trace.txt -with-timeline timeline.html -with-dag flowchart.png -resume



nextflow run main.nf  -profile singularity \
                    --input assets/samplesheet.csv \
                    --outdir output_atlantic \
                    --fasta /scratch/nadjafn/polyase_test/test_data/ATL_v3.asm.chr01_all_haplotypes.fa \
                    --gtf  /scratch/nadjafn/polyase_test/test_data/ATL_unitato_liftoff.asm.chr01_all_haplotypes.gtf \
                    --technology ONT --downsample_rate 0.99  --skip_centrifuge -resume --sqanti_dir /scratch/nadjafn/polyase_test/longrnaseq/SQANTI3 \
                    #--centrifuge_db /biodbs/centrifuge/dbs_v2018/ \
                    #--sqanti_dir /scratch/nadjafn/sqanti3/SQANTI3 \