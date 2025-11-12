

conda activate nextflow



nextflow run main.nf  -profile singularity \
                    --input assets/samplesheet.csv \
<<<<<<< HEAD
                    --outdir output_test \
                    --fasta /scratch/nadjafn/LR_DESIREE_PAPER/zenodo/longreadrna_testrun/ \
                    --gtf  /scratch/nadjafn/polyase_test/test_data/unitato2Atl.with_chloroplast_and_mito.no_scaffold.agat.gtf \
                    --technology ONT --downsample_rate 0.99  --skip_centrifuge --skip_sqanti -resume --sqanti_dir /scratch/nadjafn/sqanti3/SQANTI3 \
                    #--centrifuge_db /biodbs/centrifuge/dbs_v2018/ \
                     \
        


nextflow run main.nf -profile singularity \
                    --input assets/samplesheet_rice_Nip_2samples.csv \
                    --outdir output_rice_Nip_test \
                    --fasta /scratch/nadjafn/LR_DESIREE_PAPER/ANALYSIS/rice_example/genome/Hap1_2_Nipponbare.renamed.organels.fasta \
                    --gtf   /scratch/nadjafn/LR_DESIREE_PAPER/ANALYSIS/rice_example/genome/Hap1_2_Nipponbare.genome.renamed.organels.standard.gtf \
                    --centrifuge_db /biodbs/centrifuge/dbs_v2018/ \
                    --sqanti_dir /scratch/nadjafn/sqanti3/SQANTI3 \
                    --technology ONT --downsample_rate 0.01 
=======
                    --outdir output_atlantic \
                    --fasta /scratch/nadjafn/polyase_test/test_data/ATL_v3.asm.chr01_all_haplotypes.fa \
                    --gtf  /scratch/nadjafn/polyase_test/test_data/ATL_unitato_liftoff.asm.chr01_all_haplotypes.gtf \
                    --technology ONT --downsample_rate 0.99  --skip_centrifuge -resume --sqanti_dir /scratch/nadjafn/polyase_test/longrnaseq/SQANTI3 \
                    #--centrifuge_db /biodbs/centrifuge/dbs_v2018/ \
                    #--sqanti_dir /scratch/nadjafn/sqanti3/SQANTI3 \
>>>>>>> 43d7610750b3aa3960dac60b7825572a1b2b7389
