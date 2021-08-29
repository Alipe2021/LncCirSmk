#!/usr/bin/env python

from genericpath import exists
import re, os, yaml, json, sys
from typing_extensions import TypeVarTuple
from typing import runtime_checkable
import pandas as pd

"""
    Title:      Snakemake File for LncRNA, Novel mRNA, and Circular RNA Analysis
    Author:     Alipe
    E-mail:     sxliulian2012@hotmail.com
    Version:    1.0
    Date:       2021-05-08 16:31
    Update:     2021-08-16 11:37
"""

# 1. Raw Reads --> Clean Reads --[filter rRNA]--> rRNA-free Reads
# 2. rRNA-free Reads --[mapp to genome]--> Assembly --> Merged Info -
#    -> Re-assembly --> LncRNA/Novel mRNA Identification --> DELs/DEMs -
#    -> Target / TFs Prediction / WGCNA / miRNA Sponge ...
# 3. rRNA-free Reads --[mapp to genome]--> CircRNA Identification - 
#    -> CircRNA Quantification --> DECs --> miRNA Sponge ...
# 4. CeRNA Identification

## ================ Load Global Configurations ================= ##
configfile: 'config.yaml'             # load config file
#
OUTPUTDIR = config["output_dir"]      # output directory
SAMPLEFILES = yaml.load(open(config['sample_list']), Loader=yaml.FullLoader)  # sample files
SAMPLES = sorted(SAMPLEFILES.keys())  # sample names
#
# Need for Prediction of lncRNA, novel mRNA, and circRNA
DNA = config["dna"]     # reference genome fasta
GTF = config["gtf"]     # reference gene annotation
#
# Needed for rRNA filtering
rRNA = config["rRNA"]   # rRNAs from RNACentral or Specise-Spacial rRNA
BOWTIE2_rRNA_INDEX = config["rRNA_bowtie2_index"]   # rRNA bowtie2 index
#
# Specifically Needed for LncRNA and Novel mRNA Identification
HISAT2_SPLICE_SITES = config["splice_sites"]        # load hisat2 splice site information
HISAT2_DNA_INDEX    = config["genome_hisat2_index"]   # load hisat2 index for genome maaping
#
BED = config["bed"]     # refernece bed files
CDS = config["cds"]     # cds fasta
CDNA = config["cdna"]   # cdna fasta
NCRNA = config["ncrna"] # ncRNA fasta
MIRNA = config["mirna"] # mature miRNA fasta
MRNA_GTF = config["mrna_gtf"]       # known mRNA gtf, need for FEELnc
LNCRNA_GTF = config["lncrna_gtf"]   # known lncRNA gtf, need for FEElnc
PFAMDB = os.path.dirname(config["pfamdb"]) # PFAM database, need for Protein Prediction
#
# TRANCDS = config['TraningCDS']    # load traning cds fasta, need for CPAT
# TRANLNC = config['TraningLnc']    # load traning lncRNA fasta, need for CPAT
#
# Specifically Needed for CircRNA Identification and Quantification
BWA_DNA_INDEX   = config["genome_bwa_index"]    # bwa index for genome mapping, need for CIRI2
CIRI_QUANT_CFG  = config["ciri_quant_cfg"]      # yaml format config file for CIRIquant
#
# DEGs Analysis
COMPARE_PAIRS = config['compare_pairs']         # comparation paris
SAMPLE_GROUPS = config['sample_groups']         # sample group information
#
#
## ============================================================ ##
#                    Start Steps for each Module                 #
#                        2021-08-19 09:30                        #
#                          Edit by Alipe                         #    
##################################################################
#                                                                #
#                                                                #
#                             _oo0oo_                            #
#                            o8888888o                           #
#                            88" . "88                           #
#                            (| -_- |)                           #
#                            0\  =  /0                           #
#                          ___/`---'\___                         #
#                        .' \\|     |# '.                        #
#                       / \\|||  :  |||# \                       #
#                      / _||||| -:- |||||- \                     #
#                     |   | \\\  -  #/ |   |                     #
#                     | \_|  ''\---/''  |_/ |                    #
#                     \  .-\__  '-'  ___/-. /                    #
#                   ___'. .'  /--.--\  `. .'___                  #
#                ."" '<  `.___\_<|>_/___.' >' "".                #
#               | | :  `- \`.;`\ _ /`;.`/ - ` : | |              #
#               \  \ `_.   \_ __\ /__ _/   .-` /  /              #
#           =====`-.____`.___ \_____/___.-`___.-'=====           #
#                             `=---='                            #
#                                                                #
#         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~          #
#                                                                #
#                     佛祖保佑         永无BUG                    #
#                                                                #
##################################################################

rule all:
    input:
  ## -------------- Part 01 Data Preprocessing ---------------- ##
    # Step 00: Prepare data
        expand( OUTPUTDIR + "Part01_Common_Analysis_00.DataPrepare/{sample}.R1.fq.gz", sample=SAMPLES ),
        expand( OUTPUTDIR + "Part01_Common_Analysis_00.DataPrepare/{sample}.R2.fq.gz", sample=SAMPLES ),
    # Step 01: Quality Control
        expand( OUTPUTDIR + "Part01_Common_Analysis_01.FastqFilter/{sample}/{sample}.R1.fq.gz", sample=SAMPLES ),
        expand( OUTPUTDIR + "Part01_Common_Analysis_01.FastqFilter/{sample}/{sample}.R2.fq.gz", sample=SAMPLES ),
        expand( OUTPUTDIR + "Part01_Common_Analysis_01.FastqFilter/{sample}/{sample}.json", sample=SAMPLES ),
        expand( OUTPUTDIR + "Part01_Common_Analysis_01.FastqFilter/{sample}/{sample}.html", sample=SAMPLES ),
    # Step 02: Filter rRNA
        expand( OUTPUTDIR + "Part01_Common_Analysis_02.FilterrRNA/{sample}.bam", sample=SAMPLES ),
        expand( OUTPUTDIR + "Part01_Common_Analysis_02.FilterrRNA/{sample}/un-conc-mate.1", sample=SAMPLES ),
        expand( OUTPUTDIR + "Part01_Common_Analysis_02.FilterrRNA/{sample}/un-conc-mate.2", sample=SAMPLES ),
        expand( OUTPUTDIR + "Part01_Common_Analysis_02.FilterrRNA/{sample}/rRNA_filter.ok", sample=SAMPLES ),
    # Step 03:  Rename bowtie2 output un-conc-mate
        expand( OUTPUTDIR + "Part01_Common_Analysis_03.rRNAFreeFastq/{sample}.R1.fq.gz", sample=SAMPLES ),
        expand( OUTPUTDIR + "Part01_Common_Analysis_03.rRNAFreeFastq/{sample}.R2.fq.gz", sample=SAMPLES ),
  ##
  ## -------------- Part 02 LncRNA Identification ------------- ##
    # Step 01: Alianment to Reference Genome
        expand( OUTPUTDIR + "Part02_Common_Analysis_01.Bowtie2ToGenome/{sample}.sorted.bam", sample=SAMPLES ),
    # Step 02:
    # Step 03:
    # Step 04:
    # Step 05:
    # Step 06:
    # Step 07:
    # Step 08:
  ## -------------- Part 03 Novel mRNA Identification --------- ##
  ## -------------- Part 04 Expression Analysis --------------- ##
  ##
  ## -------------- Part 05 CircRNA Identification ------------ ##
    # Step 01: Map to Genome with BWA-MEM
        expand( OUTPUTDIR + "Part06_CircRNA_Analysis_01.BWA2Genome/{sample}.sam", sample=SAMPLES ),
    # Step 02: CircRNA identification with CIRI2
        expand( OUTPUTDIR + "Part06_CircRNA_Analysis_02.CIRI2_Prediction/{sample}.ciri", sample=SAMPLES ),
    # Step 03: CircRNA quantitation with CIRIquant
        expand( OUTPUTDIR + "Part06_CircRNA_Analysis_03.CircRNA_Quantitation/{sample}/{sample}.gtf", sample=SAMPLES ),
    # Step 04: 
    # Step 04: 
    # Step 04: 
    # Step 04: 

    #         
        ## Step 04-1: De novo Assembly Using Trinity
            # OUTPUTDIR + "Step04.TrinityAssembly/trinity_outdir/trinity_outdir.Trinity.fasta",
            # OUTPUTDIR + "Step04.TrinityAssembly/trinity_outdir/trinity_outdir.Trinity.ok
        ## Step 04-2: Reference Genome Guid Assembly
            # expand( OUTPUTDIR + "Step04.StringtieAssembly/{sample}.gtf", sample=SAMPLES ),
        # ## Step 05: Merge Assemblyed GTF
        #     OUTPUTDIR + "Step05.StringtieMerge/MergedList.txt",
        #     OUTPUTDIR + "Step05.StringtieMerge/StringtieMerged.gtf",
        #     OUTPUTDIR + "Step05.StringtieMerge/StringtieMerged.fa",
        # ## Step 06: ReAssembly Transcripts Quantify
        #     expand( OUTPUTDIR + "Step06.ReStringtieAssembly/{sample}.gtf", sample=SAMPLES ),
        #     expand( OUTPUTDIR + "Step06.ReStringtieAssembly/{sample}.coverage.cov", sample=SAMPLES ),
        #     expand( OUTPUTDIR + "Step06.ReStringtieAssembly/{sample}.GeneAbund.txt", sample=SAMPLES ),
        # ## Step 07: Gene and Transcripts Expression analysis
        #     OUTPUTDIR + "Step07.Expression/AssembledGtfList.txt",
        #     OUTPUTDIR + "Step07.Expression/gene_count_matrix.csv",
        #     OUTPUTDIR + "Step07.Expression/transcript_count_matrix.csv",
        #     OUTPUTDIR + "Step07.Expression/transcript_tpm_matrix.tsv",
        # ## Step 08: DEG Analysis
        #     # OUTPUTDIR + "Step08.DEGs/transcript_count_filter_matrix.csv",
        #     # OUTPUTDIR + "Step08.DEGs/transcript_tpm_filter_matrix.csv",
        #     # OUTPUTDIR + "Step08.DGEbyEdgeR/DGEbyEdgeR.Result.ok",
        # ## Step 09-1: LncRNA and novel mRNA identify by FEELnc
        #     OUTPUTDIR + "Step09.FEELncIdentify/Candidate_lncRNA_flt.gtf",
        #     OUTPUTDIR + "Step09.FEELncIdentify/Candidate_lncRNA_codpot.lncRNA.gtf",
        #     OUTPUTDIR + "Step09.FEELncIdentify/Candidate_lncRNA_classes.txt",
        # ## Step 09-2-1: LncRNA and novel mRNA identify by CAPT
        #     OUTPUTDIR + "Step09.CPATIdentify/Maize_Hexamer.tsv",
        #     OUTPUTDIR + "Step09.CPATIdentify/CpatMaize.feature.xls",
        #     OUTPUTDIR + "Step09.CPATIdentify/CpatMaize.logit.RData",
        #     OUTPUTDIR + "Step09.CPATIdentify/CpatMaize.make_logitModel.r",
        #     OUTPUTDIR + "Step09.CPATIdentify/CpatMaize.make_logitModel.ok",
        #     OUTPUTDIR + "Step09.CPATIdentify/CpatMaize.ORF_seqs.fa",
        #     OUTPUTDIR + "Step09.CPATIdentify/CpatMaize.ORF_prob.tsv",
        #     OUTPUTDIR + "Step09.CPATIdentify/CpatMaize.ORF_prob.best.tsv",
        #     OUTPUTDIR + "Step09.CPATIdentify/CpatMaize.no_ORF.txt",
        #     OUTPUTDIR + "Step09.CPATIdentify/CpatMaize.r",
        #     OUTPUTDIR + "Step09.CPATIdentify/CpatMaize.DetectORF.ok",
        # ## Step 10: Compare Merged GTF to Reference GTF
        #     OUTPUTDIR + "Step10.GffCompare/GffCompared.tracking",
        #     OUTPUTDIR + "Step10.GffCompare/GffCompared.annotated.gtf",
        #     OUTPUTDIR + "Step10.GffCompare/GffCompared.stats",
        #     OUTPUTDIR + "Step10.GffCompare/GffCompared.loci",
        #     OUTPUTDIR + "Step10.GffCompare/GffCompared.ok",
        # ## Step 11: LncRNA identify by CPC2,CNCI,Pfam ---- Fetch lncRNA class_code ixou, gtf, pep
        #     OUTPUTDIR + "Step11.LncRNAIdentify/Candidate_lncRNA.gtf",
        #     OUTPUTDIR + "Step11.LncRNAIdentify/Candidate_lncRNA.fa",
        #     OUTPUTDIR + "Step11.LncRNAIdentify/Candidate_lncRNA.pep.fa",
        # ## Step 12: LncRNA identify by CPC2,CNCI,Pfam ---- LncRNA Protein Coding detection -- (CPC2,CNCI,PFAM)
        #     OUTPUTDIR + "Step12.CPC2LncRNAProteinPrediction/LncRNA_CPC2_Out.txt",
        #     OUTPUTDIR + "Step12.CPC2LncRNAProteinPrediction/LncRNA_CPC2_Noncoding.txt",
        #     OUTPUTDIR + "Step12.CNCILncRNAProteinPrediction/LncRNA_CNCI/CNCI.index",
        #     OUTPUTDIR + "Step12.CNCILncRNAProteinPrediction/LncRNA_CNCI_Noncoding.txt",
        #     OUTPUTDIR + "Step12.PfamScanLncRNAPrediction/LncRNA_PfamScan.Result.txt",
        #     OUTPUTDIR + "Step12.PfamScanLncRNAPrediction/LncRNA_PfamScan_Coding.txt",
        # ## Step 13: Novel mRNA identify by CPC2,CNCI,Pfam ---- Fetch novel mRNA class_code uj, orf, pep
        #     OUTPUTDIR + "Step13.NovelmRNAIdentify/Candidate_Novel_mRNA.gtf",
        #     OUTPUTDIR + "Step13.NovelmRNAIdentify/Candidate_Novel_mRNA.fa",
        #     OUTPUTDIR + "Step13.NovelmRNAIdentify/Candidate_Novel_mRNA.orf_cds.fa",
        #     OUTPUTDIR + "Step13.NovelmRNAIdentify/Candidate_Novel_mRNA.orf_pep.fa",
        # ## Step 14: Novel mRNA identify by CPC2,CNCI,Pfam ---- Novel mRNA Protein Coding detection (CPC2,CNCI,PFAM)
        #     OUTPUTDIR + "Step14.CPC2NovelmRNAProteinPrediction/NovelmRNA_CPC2_Out.txt",
        #     OUTPUTDIR + "Step14.CPC2NovelmRNAProteinPrediction/NovelmRNA_CPC2_Coding.txt",
        #     OUTPUTDIR + "Step14.CNCINovelmRNAProteinPrediction/NovelmRNA_CNCI/CNCI.index",
        #     OUTPUTDIR + "Step14.CNCINovelmRNAProteinPrediction/NovelmRNA_CNCI_Coding.txt",
        #     OUTPUTDIR + "Step14.PfamScanNovelmRNAPrediction/NovelmRNA_PfamScan.Result.txt",
        #     OUTPUTDIR + "Step14.PfamScanNovelmRNAPrediction/NovelmRNA_PfamScan_Coding.txt",
        ## Step 15: Cis and trans target gene
        ## Step 16: Target by known miRNA
        ## Step 17: 
        ## Step 18: 
        ## Step 19: 
        ## Report S01: Fastq Filter Result
            # OUTPUTDIR + "Report/S01.FastqFilter.jsonlist.txt",
            # OUTPUTDIR + "Report/S01.FastqFilter-State.tsv"
        ## Report S03: Read distribution by RseQC 3.0
            # expand( OUTPUTDIR + "Report/S03.ReadDistribution/{sample}.state.tsv", sample=SAMPLES )
#
##################################################################
## ================ Part 01 Data Preprocessing ================ ##
##################################################################
#
# Step 00: Prepare data
rule Part01_Preprocess_00_PrepareFastqFile:
    input:
        lambda wildcards:SAMPLEFILES[wildcards.sample]
    output:
       R1 =  OUTPUTDIR + "Part01_Preprocess/00.DataPrepare/{sample}.R1.fq.gz",
       R2 =  OUTPUTDIR + "Part01_Preprocess/00.DataPrepare/{sample}.R2.fq.gz"
    shell:
        "ln -sf {input[0]} {output.R1} && "
        "ln -sf {input[1]} {output.R2} "
# Step 01: Quality Control
rule Part01_Preprocess_01_FastqFilter:
    input:
        R1 =  OUTPUTDIR + "Part01_Preprocess/00.DataPrepare/{sample}.R1.fq.gz",
        R2 =  OUTPUTDIR + "Part01_Preprocess/00.DataPrepare/{sample}.R2.fq.gz"
    output:
        R1   = OUTPUTDIR + "Part01_Preprocess/01.FastqFilter/{sample}/{sample}.R1.fq.gz",
        R2   = OUTPUTDIR + "Part01_Preprocess/01.FastqFilter/{sample}/{sample}.R2.fq.gz",
        json = OUTPUTDIR + "Part01_Preprocess/01.FastqFilter/{sample}/{sample}.json",
        html = OUTPUTDIR + "Part01_Preprocess/01.FastqFilter/{sample}/{sample}.html"
    message:
        "Begin to filter fastq!"
    log:
        OUTPUTDIR + "AllLogs/Part01_Preprocess/01.FastqFilter/{sample}.FastqFilter.log"
    params:
        "--detect_adapter_for_pe --average_qual 15"
    threads:
        8
    shell:
        """
        fastp {params} -w {threads} -i {input.R1} -I {input.R2} -o {output.R1} \
        -O {output.R2} -j {output.json} -h {output.html} 2> {log}
        """
# Step 02: rRNA filter
rule Part01_Preprocess_02_FilterrRNA:
    input:
        R1 = OUTPUTDIR + "Part01_Preprocess/01.FastqFilter/{sample}/{sample}.R1.fq.gz",
        R2 = OUTPUTDIR + "Part01_Preprocess/01.FastqFilter/{sample}/{sample}.R2.fq.gz",
        idx = BOWTIE2_rRNA_INDEX
    output:
        bam  = OUTPUTDIR + "Part01_Preprocess/02.FilterrRNA/{sample}.bam",
        stat = OUTPUTDIR + "Part01_Preprocess/02.FilterrRNA/{sample}/rRNA_filter.ok",
        R1   = OUTPUTDIR + "Part01_Preprocess/02.FilterrRNA/{sample}/un-conc-mate.1",
        R2   = OUTPUTDIR + "Part01_Preprocess/02.FilterrRNA/{sample}/un-conc-mate.2"
    message:
        "Start to filter rRNA baseed on RNACentral plant rRNA database by bowtie2."
    log:
        OUTPUTDIR + "AllLogs/Part01_Preprocess/02.FilterrRNA/{sample}.align.logs"
    threads:
        8
    params:
        opt = "-q --phred33 --sensitive --end-to-end --fr",
        out = OUTPUTDIR + "Part01_Preprocess/02.FilterrRNA/{sample}"
    shell:
        """
        bowtie2 {params.opt} -p {threads} --un-conc-gz {params.out} -x {input.idx} \
        -1 {input.R1} -2 {input.R2} 2>{log} | samtools sort -n -O Bam -@ 4 \
        -m 5G -o {output.bam} && echo Success > {output.stat}
        """
# Step 03: Rename bowtie2 un-conc-gz
rule Part01_Common_Analysis_03_RenameBowtieOut:
    input:
        stat = OUTPUTDIR + "Part01_Preprocess/02.FilterrRNA/{sample}/rRNA_filter.ok",
        R1   = OUTPUTDIR + "Part01_Preprocess/02.FilterrRNA/{sample}/un-conc-mate.1",
        R2   = OUTPUTDIR + "Part01_Preprocess/02.FilterrRNA/{sample}/un-conc-mate.2"
    output:
        R1 = OUTPUTDIR + "Part01_Preprocess/03.rRNAFreeFastq/{sample}.R1.fq.gz",
        R2 = OUTPUTDIR + "Part01_Preprocess/03.rRNAFreeFastq/{sample}.R2.fq.gz"
    shell:
        """
        ln -sf {input.R1} {output.R1} && \
        ln -sf {input.R2} {output.R2}
        """
#
##################################################################
## ================ Part 02 Mapping and Assembly ============== ##
##################################################################
#
# Step 01: Align to reference genome
rule Part02_MappingAndAssembly_01_Hisat2Genome:
    input:
        R1 = OUTPUTDIR + "Part01_Preprocess/03.rRNAFreeFastq/{sample}.R1.fq.gz",
        R2 = OUTPUTDIR + "Part01_Preprocess/03.rRNAFreeFastq/{sample}.R2.fq.gz",
        SS = HISAT2_SPLICE_SITES, # if hisat2-build with ss and exon, skip this step.
        GTF = GTF,
        IDX = HISAT2_DNA_INDEX
    output:
        BAM = OUTPUTDIR + "Part02_MappingAndAssembly/01.Hisat2Genome/{sample}.bam",
        SUM = OUTPUTDIR + "Part02_MappingAndAssembly/01.Hisat2Genome/{sample}.summary.txt",
        R1  = OUTPUTDIR + "Part02_MappingAndAssembly/01.Hisat2Genome/{sample}/un-conc-mate.1",
        R2  = OUTPUTDIR + "Part02_MappingAndAssembly/01.Hisat2Genome/{sample}/un-conc-mate.2"
    message:
        "Start to map  genome with hisat2."
    log:
        OUTPUTDIR + "AllLogs/Part02_MappingAndAssembly/01.Hisat2Genome/{sample}.align.logs"
    threads:
        8
    params:
        OPT = "-q --phred33 --min-intronlen 20 --max-intronlen 150000 --dta",
        DIR = OUTPUTDIR + "Part02_MappingAndAssembly/01.Hisat2Genome/{sample}"
    shell:
        """
        hisat2 {params.OPT} -p {threads} --summary-file {output.SUM} -x {input.IDX} \
            --known-splicesite-infile {input.SS} --un-conc-gz {params.DIR} \
            -1 {input.R1} -2 {input.R2} 2>{log} | samtools sort -O Bam \
            -@ {threads} -m 5G -o {output.BAM}
        """
# Step 02: ReName un-conc-gz
rule Part02_MappingAndAssembly_02_ReNameHisat2Out:
    input:
        R1 = OUTPUTDIR + "Part02_MappingAndAssembly/01.Hisat2Genome/{sample}/un-conc-mate.1",
        R2 = OUTPUTDIR + "Part02_MappingAndAssembly/01.Hisat2Genome/{sample}/un-conc-mate.2",
    output:
        R1 = OUTPUTDIR + "Part02_MappingAndAssembly/02.Hisat2Rename/{sample}.R1.fq.gz",
        R2 = OUTPUTDIR + "Part02_MappingAndAssembly/02.Hisat2Rename/{sample}.R2.fq.gz"
    shell:
        """
        ln -sf {input.R1} {output.R1} && \
        ln -sf {input.R2} {output.R2}
        """
# Step 03: Trinity Assembly
rule Part02_MappingAndAssembly_03_TrinityAssembly:
    input:
        samList = TINITY_SAMPLE_LIST
    output:
        fa = OUTPUTDIR + "Part02_MappingAndAssembly/03.TrinityAssembly/trinity_outdir.Trinity.fasta",
        ok = OUTPUTDIR + "Part02_MappingAndAssembly/03.TrinityAssembly/trinity_outdir.Trinity.ok"
    log:
        OUTPUTDIR + "logs/Part02_MappingAndAssembly/03.TrinityAssembly/TrinityAssembly.log"
    message:
        "Start De novo Assembly useing trinity!"
    resources:
        mem_mb=100000
    threads:
        20
    params:
        opt = "--seqType fq --max_memory 100G --full_cleanup",
        outdir = OUTPUTDIR + "Part02_MappingAndAssembly/03.TrinityAssembly/"
    shell:
        """
        source activate tinity_env && \
        Trinity {params.opt} --samples_file {input.samList} --CPU {threads} --output {params.outdir} && \
        if [[ -s {output.fa} ]]; then echo SUCCESS ! > {output.ok}; fi && \
        conda deactivate
        """
# Step 04: Stringtie Assembly
rule Part02_MappingAndAssembly_04_StringtieAssembly:
    input:
        bam = OUTPUTDIR + "Part02_MappingAndAssembly/01.Hisat2Genome/{sample}.bam",
        gtf = GTF,
    output:
        gtf = OUTPUTDIR + "Part02_MappingAndAssembly/04.StringtieAssembly/{sample}.gtf"
    message:
        "Start to assembly use stringtie."
    log:
        OUTPUTDIR + "AllLogs/Part02_MappingAndAssembly/04.StringtieAssembly/{sample}.assembly.logs"
    threads:
        8
    params:
        "-m 200 -l STRG -a 10 --conservative -g 50 -u"
    shell:
        """
        stringtie {input.bam} -G {input.gtf} -o {output.gtf} -p {threads} {params}
        """
# Step 05: Make gtf List
rule Part02_MappingAndAssembly_05_MakeMergeList:
    input:
        expand(OUTPUTDIR + "Part02_MappingAndAssembly/04.StringtieAssembly/{sample}.gtf", sample = SAMPLES)
    output:
        OUTPUTDIR  + "Part02_MappingAndAssembly/05.MakeGtfMergeList/MergedList.txt"
    run:
        with open(output, 'w') as f:
            for gtf in input:
                print(gtf, file=f)
# Step 06: Merge transcript
rule Part02_MappingAndAssembly_06_StringtieMerge:
    input:
        lst = OUTPUTDIR + "Part02_MappingAndAssembly/05.MakeGtfMergeList/MergedList.txt"
        gtf = GTF
    output:
        gtf = OUTPUTDIR + "Part02_MappingAndAssembly/06.StringtieMerge/StringtieMerged.gtf"
    log:
        OUTPUTDIR + "AllLogs/Part02_MappingAndAssembly/06.StringtieMerge/StringtieMerge.logs"
    threads:
        8
    params:
        "-m 200 -c 3"
    shell:
        """
        stringtie --merge {params} -p {threads} -G {input.gtf} -o {output.gtf} {input.lst} 2> {log}
        """
# Step 07: Compare to reference annotation
rule Part02_MappingAndAssembly_07_Compare2Ref:
    input:
        RefGtf = GTF,
        ComGtf = OUTPUTDIR + "Part02_MappingAndAssembly/06.StringtieMerge/StringtieMerged.gtf"
    output:
        gtf   = OUTPUTDIR + "Part02_MappingAndAssembly/07.Compare2Ref/GffCompared.annotated.gtf",
        stats = OUTPUTDIR + "Part02_MappingAndAssembly/07.Compare2Ref/GffCompared.stats",
        track = OUTPUTDIR + "Part02_MappingAndAssembly/07.Compare2Ref/GffCompared.tracking",
        loci  = OUTPUTDIR + "Part02_MappingAndAssembly/07.Compare2Ref/GffCompared.loci",
        ojbk  = OUTPUTDIR + "Part02_MappingAndAssembly/07.Compare2Ref/GffCompared.ok"
    log:
        OUTPUTDIR + "AllLogs/Part02_MappingAndAssembly/07.Compare2Ref/GffCompared.logs"
    threads:
        1
    params:
        opt = "-T -R",
        pfx = OUTPUTDIR + "Part02_MappingAndAssembly/07.Compare2Ref/GffCompared",
    shell:
        """
        gffcompare {params.opt} -r {input.RefGtf} -o {params.pfx} {input.ComGtf} 2> {log} && \
        echo SUCCESS > {output.ojbk}
        """
#
##################################################################
## ================ Part 03 LncRNA Identification ============= ##
##################################################################
#
# Step 01: Fetch class code "i", "o", "x", and "u"
rule Part03_LncRNA_Identification_01_FetchCandidateLncRNAGtf:
    input:
        gtf  = OUTPUTDIR + "Part02_MappingAndAssembly/07.Compare2Ref/GffCompared.annotated.gtf",
        ojbk = OUTPUTDIR + "Part02_MappingAndAssembly/07.Compare2Ref/GffCompared.ok"
    output:
        gtf = OUTPUTDIR + "Part03_LncRNA_Identification/01.CandidateLncRNAGtf/GffCompared.ioux.gtf"
    threads:
        1
    params:
        "iuxo"
    shell:
        """
        perl Scripts/Fetch.class_code_gtf.pl {input} {params} > {output}
        """
# Step 02: Fetch Candidate lncRNA fasta
rule Part03_LncRNA_Identification_02_FetchCandidatelncRNAFas:
    input:
        dna = DNA,
        gtf = OUTPUTDIR + "Part03_LncRNA_Identification/01.CandidateLncRNAGTF/GffCompared.ioux.gtf"
    output:
        fna = OUTPUTDIR + "Part03_LncRNA_Identification/02.CandidatelncRNAFas/GffCompared.ioux.fa",
        tmp = OUTPUTDIR + "Part03_LncRNA_Identification/02.CandidatelncRNAFas/GffCompared.ioux.tmp",
        pep = OUTPUTDIR + "Part03_LncRNA_Identification/02.CandidatelncRNAFas/GffCompared.ioux.pep.fa"
    log:
        OUTPUTDIR + "AllLogs/Part03_LncRNA_Identification/02.CandidatelncRNAFas/Candaidate_lncRNA_fa_fetch.log"
    threads:
        1
    shell:
        """
        gffread -w {output.fna} -g {input.dna} {input.gtf} && transeq {output.fna} \
        {output.tmp} && sed 's/*//g' {output.tmp} > {output.pep} 2> {log}
        """
# Step 03: lncRNA protein coding potential prodiction with CPC2
rule Part03_LncRNA_Identification_03_CPC2_Predict:
    input:
        fas = OUTPUTDIR + "Part03_LncRNA_Identification/02.CandidatelncRNAFas/GffCompared.ioux.fa",
    output:
        cpc = protected(OUTPUTDIR + "Part03_LncRNA_Identification/03.CPC2_Predict/CPC2PredictOut.txt"),
        noc = protected(OUTPUTDIR + "Part03_LncRNA_Identification/03.CPC2_Predict/CPC2_Noncoding.txt")
    log:
        OUTPUTDIR + "AllLogs/Part03_LncRNA_Identification/03.CPC2_Predict/CPC2Predict.log"
    threads:
        1
    params:
        dir = OUTPUTDIR + "Part03_LncRNA_Identification/03.CPC2_Predict/"
    run:
        import os
        import subprocess
        if not os.path.exists(params.dir):
            os.makedirs(params.dir)
        cmd = """
        source activate cpc2_py2_env && \
        CPC2.py -i {fas} -o {cpc} 2> {log} && grep -w "noncoding" {cpc} | cut -f1 > {noc}
        """.format(fas = input.fas, log = log, cpc = output.cpc, noc = output.noc)
        subprocess.call(cmd, shell = True)
        # sz = os.path.getsize(output.noc)
        # if sz > 0:
        #     subprocess.call("echo SUCCESS > {ok}".format(ok = output.ok), shell = True)
# Step 04: LncRNA protein coding potential prediction with CNCI
rule Part03_LncRNA_Identification_04_CNCI_Predict:
    input:
        OUTPUTDIR + "Part03_LncRNA_Identification/02.CandidatelncRNAFas/GffCompared.ioux.fa",
    output:
        cnci = protected(OUTPUTDIR + "Part03_LncRNA_Identification/04.CNCI_Predict/CNCI_Predict/CNCI.index"),
        noc  = OUTPUTDIR + "Part03_LncRNA_Identification/04.CNCI_Predict/CNCI_Noncoding.txt"
    log:
        OUTPUTDIR + "AllLogs/Part03_LncRNA_Identification/04.CNCI_Predict/CNCI_Predict.log"
    threads:
        20
    params:
        opt = "-m ve",
        out = OUTPUTDIR + "Part03_LncRNA_Identification/04.CNCI_Predict/CNCI_Predict"
    shell:
        """
        source activate cnci_py2_env && \
        CNCI.py -f {input} -o {params.out} -p {threads} {params.opt} 2> {log} && \
        grep -w "noncoding" {output.cnci} | cut -f1 > {output.noc}
        """
# Step 05: LncRNA protein coding potential prediction with PfamScan
rule Part03_LncRNA_Identification_05_Pfam_Predict:
    input:
        OUTPUTDIR + "Part03_LncRNA_Identification/02.CandidatelncRNAFas/GffCompared.ioux.fa",
    output:
        res = protected(OUTPUTDIR + "Part03_LncRNA_Identification/05.Pfam_Predict/PfamPredictOut.txt"),
        cod = protected(OUTPUTDIR + "Part03_LncRNA_Identification/05.Pfam_Predict/Pfam_Coding.txt")
    log:
        OUTPUTDIR + "AllLogs/Part03_LncRNA_Identification/05.Pfam_Predict/PfamPredict.log"
    threads:
        20
    params:
        db = PFAMDB
    shell:
        """
        source activate pfam_scan_env && \
        pfam_scan.pl -cpu {threads} -fasta {input} -dir {params.db} -outfile {output.res} 2> {log} && \
        grep -v "#" {output.res} |cut -f1 > {output.cod}
        """
# Step 06: LncRNA Identification by FEElnc, S1: filter
rule Part03_LncRNA_Identification_06_FEELnc_filter:
    input:
        RefGtf = GTF,
        ComGtf = OUTPUTDIR + "Part03_LncRNA_Identification/01.CandidateLncRNAGtf/GffCompared.ioux.gtf"
    output:
        flt = OUTPUTDIR + "Part03_LncRNA_Identification/06.FEELnc_filter/Candidate_lncRNA_flt.gtf"
    log:
        OUTPUTDIR + "AllLogs/Part03_LncRNA_Identification/06.FEELnc_filter/FEELncPrediction.flt.log",
    threads:
        20
    params:
        "-s 200 -b transcript_biotype=protein_coding --monoex=0 --biex=25 -l FALSE"        
    shell:
        """
        source activate feelnc_env && \
        FEELnc_filter.pl {params} -p {threads} -i {input.ComGtf} -a {input.RefGtf} -o {log} > {output.flt}
        """
# Step 07: LncRNA Identification by FEElnc, S2: codpot predict
rule Part03_LncRNA_Identification_07_FEELnc_codpot:
    input:
        RefGtf = DNA,
        RefGtf = GTF,
        mRNAGtf   = MRNA_GTF,
        lncRNAGtf = LNCRNA_GTF,
        flt = OUTPUTDIR + "Part03_LncRNA_Identification/06.FEELnc_filter/Candidate_lncRNA_flt.gtf"
    output:
        cod = OUTPUTDIR + "Part03_LncRNA_Identification/07.FEELnc_codpot/Candidate_lncRNA_codpot.lncRNA.gtf",
        rna = OUTPUTDIR + "Part03_LncRNA_Identification/07.FEELnc_codpot/Candidate_lncRNA_codpot.mRNA.gtf",
        orf = OUTPUTDIR + "Part03_LncRNA_Identification/07.FEELnc_codpot/Candidate_lncRNA_codpot.noORF.gtf",
        rld = OUTPUTDIR + "Part03_LncRNA_Identification/07.FEELnc_codpot/Candidate_lncRNA_codpot_RF_learningData.txt",
        rsc = OUTPUTDIR + "Part03_LncRNA_Identification/07.FEELnc_codpot/Candidate_lncRNA_codpot_RF_statsLearn_CrossValidation.txt",
        rft = OUTPUTDIR + "Part03_LncRNA_Identification/07.FEELnc_codpot/Candidate_lncRNA_codpot_RF.txt"
    log:
        OUTPUTDIR + "AllLogs/Part03_LncRNA_Identification/07.FEELnc_codpot/FEELncPrediction.codpot.log"
    threads:
        20
    params:
        cod_opt1 = "-b transcript_biotype=protein_coding --mode=shuffle --sizeinter=0.75",
        cod_opt2 = "--learnorftype=3 --testorftype=3 --ntree 500 --seed=1234",
        cod_dir = OUTPUTDIR + "Part03_LncRNA_Identification/07.FEELnc_codpot/",
        cod_name = "Candidate_lncRNA_codpot"
    shell:
        """
        source activate feelnc_env && \
        FEELnc_codpot.pl {params.cod_opt1} {params.cod_opt2} -p {threads} -i {input.flt} -a {input.RefGtf} \
            -g {input.RefGtf} -l {input.lncRNAGtf} --outdir={params.cod_dir} --outname={params.cod_name} 2> {log}
        """
# Step 08: LncRNA Identification by FEElnc, S3: classifier
rule Part03_LncRNA_Identification_08_FEELnc_classifier:
    input:
        RefGtf = GTF,
        CodGtf = OUTPUTDIR + "Part03_LncRNA_Identification/07.FEELnc_codpot/Candidate_lncRNA_codpot.lncRNA.gtf"
    output:        
        OUTPUTDIR + "Part03_LncRNA_Identification/08.FEELnc_classifier/Candidate_lncRNA_classes.txt"
    log:
        OUTPUTDIR + "AllLogs/Part03_LncRNA_Identification/08.FEELnc_classifier/FEELncPrediction.class.log"
    threads:
        1
    shell:
        """
        source activate feelnc_env && \
        FEELnc_classifier.pl -i {input.CodGtf} -a {input.RefGtf} > {output} -l {log}
        """
#
##################################################################
## ================ Part 04 Novel mRNA Identification ========= ##
##################################################################
#
# Step 01: Fetch Candidate Novel mRNA GTF
rule Part04_NovelmRNA_Identification_01_FetchCandidateNovelmRNAGtf:
    input:
        gtf  = OUTPUTDIR + "Part02_MappingAndAssembly/07.Compare2Ref/GffCompared.annotated.gtf",
        ojbk = OUTPUTDIR + "Part02_MappingAndAssembly/07.Compare2Ref/GffCompared.ok"
    output:
        OUTPUTDIR + "Part04_NovelmRNA_Identification/01.FetchCandidateNovelmRNAGtf/GffCompared.ju.gtf"
    log:
        OUTPUTDIR + "AllLogs/Part04_NovelmRNA_Identification/01.FetchCandidateNovelmRNAGtf/FetchCandidateNovelmRNAGtf.log"
    threads:
        1
    params:
        "ju"
    shell:
        """
        perl Scripts/Fetch.class_code_gtf.pl {input.gtf} {params} > {output} 2> {log}
        """      
# Step 02: Fetch Candidate Novel mRNA fasta
rule Part04_NovelmRNA_Identification_02_FetchCandidateNovelmRNAFas:
    input:
        dna = DNA,
        gtf = OUTPUTDIR + "Part04_NovelmRNA_Identification/01.FetchCandidateNovelmRNAGtf/GffCompared.ju.gtf"
    output:
        OUTPUTDIR + "Part04_NovelmRNA_Identification/02.FetchCandidateNovelmRNAFas/GffCompared.ju.fa"
    log:
        OUTPUTDIR + "AllLogs/Part04_NovelmRNA_Identification/02.FetchCandidateNovelmRNAFas/FetchCandidateNovelmRNAFas.log"
    threads:
        1
    shell:
        """
        gffread -w {output} -g {input.dna} {input.gtf} 2> {log}
        """
# Step 03: Fetch Gene<\t>Transcript table
rule Part04_NovelmRNA_Identification_03_FetchGene2Tanscript:
    input:
        OUTPUTDIR + "Part04_NovelmRNA_Identification/01.FetchCandidateNovelmRNAGtf/GffCompared.ju.gtf"
    output:
        OUTPUTDIR + "Part04_NovelmRNA_Identification/03.Gene2Tanscript/GffCompared_ju.g2t.txt"
    threads:
        1    
    shell:
        """
        perl Scripts/Fetch.gene2transcript.pl {input} > {output}
        """
# Step 04: Fetch Candidate Novel mRNA ORF
rule Part04_NovelmRNA_Identification_04_TransDecoderLongOrfs:
    input:
        fna = OUTPUTDIR + "Part04_NovelmRNA_Identification/02.FetchCandidateNovelmRNAFas/GffCompared.ju.fa",
        g2t = OUTPUTDIR + "Part04_NovelmRNA_Identification/03.Gene2Tanscript/GffCompared_ju.g2t.txt"
    output:
        cds = protected(OUTPUTDIR + "Part04_NovelmRNA_Identification/04.TransDecoderLongOrfs/longest_orfs.cds"),
        pep = protected(OUTPUTDIR + "Part04_NovelmRNA_Identification/04.TransDecoderLongOrfs/longest_orfs.pep"),
        gff = protected(OUTPUTDIR + "Part04_NovelmRNA_Identification/04.TransDecoderLongOrfs/longest_orfs.gff3")
    log:
        OUTPUTDIR + "AllLogs/Part04_NovelmRNA_Identification/04.TransDecoderLongOrfs/TransdecoderORF_Fetch.log"
    threads:
        1
    params:
        opt = "-m 100 -S",
        DIR = OUTPUTDIR + "Part04_NovelmRNA_Identification/04.TransDecoderLongOrfs/"
    shell:
        """
        TransDecoder.LongOrfs {params.opt} -t {input.fna} --gene_trans_map {input.g2t} --output_dir {params.DIR} 2> {log}
        """
# Step 05: Novel mRNA protein coding potential prodict by CPC2
rule Part04_NovelmRNA_Identification_05_CodingPotential.CPC2:
    input:
        cds = OUTPUTDIR + "Part04_NovelmRNA_Identification/04.TransDecoderLongOrfs/longest_orfs.cds"
    output:
        cpc = protected(OUTPUTDIR + "Part04_NovelmRNA_Identification/05.CodingPotential_CPC2/CPC2PredictOut.txt"),
        cod = protected(OUTPUTDIR + "Part04_NovelmRNA_Identification/05.CodingPotential_CPC2/CPC2_Coding.txt"),
    log:
        OUTPUTDIR + "AllLogs/Part04_NovelmRNA_Identification/05.CodingPotential_CPC2/CPC2Prediction.log"
    threads:
        1
    params:
        DIR = OUTPUTDIR + "Part04_NovelmRNA_Identification/05.CodingPotential_CPC2/",
        pfx = OUTPUTDIR + "Part04_NovelmRNA_Identification/05.CodingPotential_CPC2/CPC2PredictOut"
    run:
        import os
        import subprocess
        if not os.path.exists(params.dir):
            os.makedirs(params.dir)
        
        cmd = """
        source activate cpc2_py2_env && \
        CPC2.py -i {cds} -o {cpc} 2> {log} && grep -w "noncoding" {cpc} | cut -f1 > {noc}
        """.format(fas = input.cds, log = log, cpc = output.cpc, noc = output.noc)
        subprocess.call(cmd, shell = True)
# Step 06: Novel mRNA protein coding potential prodict by CNCI
rule Part04_NovelmRNA_Identification_06_CodingPotential.CNCI:
    input:
        cds = OUTPUTDIR + "Part04_NovelmRNA_Identification/04.TransDecoderLongOrfs/longest_orfs.cds"
    output:
        cnci = protected(OUTPUTDIR + "Part04_NovelmRNA_Identification/06.CodingPotential_CNCI/CNCI.index"),
        cod = protected(OUTPUTDIR + "Part04_NovelmRNA_Identification/06.CodingPotential_CNCI/CNCI_Coding.txt")
    log:
        OUTPUTDIR + "AllLogs/Part04_NovelmRNA_Identification/06.CodingPotential_CNCI/CNCI_Prediction.log"
    threads:
        10
    params:
        opt = "-m ve",
        out = OUTPUTDIR + "Part04_NovelmRNA_Identification/06.CodingPotential_CNCI/"
    shell:
        """
        source activate cnci_py2_env && \
        CNCI.py -f {input} -o {params.out} -p {threads} {params.opt} 2> {log} && \
        grep -w "coding" {output.cnci} | cut -f1 > {output.cod}
        """
# Step 07: Novel mRNA protein coding potential prodict by Pfam
rule Part04_NovelmRNA_Identification_07_CodingPotential.Pfam:
    input:
        OUTPUTDIR + "Part04_NovelmRNA_Identification/04.TransDecoderLongOrfs/longest_orfs.pep"
    output:
        res = OUTPUTDIR + "Part04_NovelmRNA_Identification/07.CodingPotential_Pfam/PfamPredictOut.txt",
        cod = OUTPUTDIR + "Part04_NovelmRNA_Identification/07.CodingPotential_Pfam/Pfam_Coding.txt",
    log:
        OUTPUTDIR + "AllLogs/Part04_NovelmRNA_Identification/07.CodingPotential_Pfam/PfamPredictOut.log"
    threads:
        20
    params:
        db = PFAMDB
    shell:
        """
        source activate pfam_scan_env && \
        pfam_scan.pl -cpu {threads} -fasta {input} -dir {params.db} -outfile {output.res} 2> {log} && \
        grep -v "#" {input} |cut -f1 > {output.cod}
        """
# Step 08: Random fetch fas for CPAT
rule Part04_NovelmRNA_Identification_08_RandomFetchFas:
    input:
        cds = CDS,
        noc = NCRNA,
    output:
        cds = OUTPUTDIR + "Part04_NovelmRNA_Identification/08.RandomFetchFas/Traning_CDS.fa",
        noc = OUTPUTDIR + "Part04_NovelmRNA_Identification/08.RandomFetchFas/Traning_Noc.fa",
    shell:
        """
        perl Scripts/RandomFetchFas.pl {input.cds} > {output.cds} && \
        perl Scripts/RandomFetchFas.pl {input.noc} > {output.noc}
        """    
# Step 09: Novel mRNA protein coding potential prodict by CPAT-BuildHexamerTable
rule Part04_NovelmRNA_Identification_09_CPATBuildHexamerTable:
    input:
        cds = OUTPUTDIR + "Part04_NovelmRNA_Identification/08.RandomFetchFas/Traning_CDS.fa",
        noc = OUTPUTDIR + "Part04_NovelmRNA_Identification/08.RandomFetchFas/Traning_Noc.fa",
    output:
        OUTPUTDIR + "Part04_NovelmRNA_Identification/09.CPATBuildHexamerTable/Maize_Hexamer.tsv"
    log:
        OUTPUTDIR + "AllLogs/Part04_NovelmRNA_Identification/09.CPATBuildHexamerTable/CPATBuildHexamerTable.log"
    threads:
        1
    shell:
        """
        source activate cpat_env && \
        make_hexamer_tab.py {params} -c {input.cds} -n {input.ncrna} > {output} 2> {log}
        """
# Step 10: Novel mRNA protein coding potential prodict by CPAT-Build Logit Model
rule Part04_NovelmRNA_Identification_10_CPATBuildLogitModel:
    input:
        cod = CDNA,
        noc = NCRNA,
        hex = OUTPUTDIR + "Part04_NovelmRNA_Identification/09.CPATBuildHexamerTable/Maize_Hexamer.tsv"
    output:
        feature = OUTPUTDIR + "Part04_NovelmRNA_Identification/10.CPATBuildLogitModel/CpatMaize.feature.xls",
        rdata = OUTPUTDIR + "Part04_NovelmRNA_Identification/10.CPATBuildLogitModel/CpatMaize.logit.RData",
        rscipt = OUTPUTDIR + "Part04_NovelmRNA_Identification/10.CPATBuildLogitModel/CpatMaize.make_logitModel.r"
    log:
        OUTPUTDIR + "AllLogs/Part04_NovelmRNA_Identification/10.CPATBuildLogitModel/CPATBuildLogitModel.log"
    params:
        opt = "--min-orf=30",
        pfx = OUTPUTDIR + "Part04_NovelmRNA_Identification/10.CPATBuildLogitModel/CpatMaize"
    shell:
        """
        source activate cpat_env && \
        make_logitModel.py {params.opt} -x {input.hex} -c {input.cod} -n {input.noc} -o {params.pfx} --log-file={log}
        """
# Step 11: Novel mRNA protein coding potential prodict by CPAT -- Detect ORF
rule Part04_NovelmRNA_Identification_11_CPATtoDetectORF:
    input:
        cds = OUTPUTDIR + "Part04_NovelmRNA_Identification/04.TransDecoderLongOrfs/longest_orfs.cds",
        hex = OUTPUTDIR + "Part04_NovelmRNA_Identification/09.CPATBuildHexamerTable/Maize_Hexamer.tsv",
        rdata = OUTPUTDIR + "Part04_NovelmRNA_Identification/10.CPATBuildLogitModel/CpatMaize.logit.RData",
    output:
        seqs = protected(OUTPUTDIR + "Part04_NovelmRNA_Identification/11.CPATtoDetectORF/CpatMaize.ORF_seqs.fa"),
        peob = protected(OUTPUTDIR + "Part04_NovelmRNA_Identification/11.CPATtoDetectORF/CpatMaize.ORF_prob.tsv"),
        best = protected(OUTPUTDIR + "Part04_NovelmRNA_Identification/11.CPATtoDetectORF/CpatMaize.ORF_prob.best.tsv"),
        norf = protected(OUTPUTDIR + "Part04_NovelmRNA_Identification/11.CPATtoDetectORF/CpatMaize.no_ORF.txt"),
        rscript = protected(OUTPUTDIR + "Part04_NovelmRNA_Identification/11.CPATtoDetectORF/CpatMaize.r")
    log:
        OUTPUTDIR + "AllLogs/Part04_NovelmRNA_Identification/11.CPATtoDetectORF/CPATtoDetectORF.log"
    params:
        opt = "--top-orf=5 --antisense --min-orf=100 --width=100 --best-orf=p",
        pfx = OUTPUTDIR + "Part04_NovelmRNA_Identification/11.CPATtoDetectORF/CpatMaize"
    threads:
        1
    shell:
        """
        source activate cpat_env && \
        cpat.py {params.opt} -x {input.hex} -d {input.rdata} -g {input.cds} -o {params.pfx} --log-file={log}
        """
#
##################################################################
## ================ Part 05 Expression Analysis =============== ##
##################################################################
#
# Step 01: Re Assembly by Stringtie
rule Part05_Expression_Analysis_01_ReStringtieAssemble:
    input:
        bam = OUTPUTDIR + "Part02_MappingAndAssembly/01.Hisat2Genome/{sample}.bam",
        gtf = OUTPUTDIR + "Part02_MappingAndAssembly/06.StringtieMerge/StringtieMerged.gtf"
    output:
        gtf = OUTPUTDIR + "Part05_Expression_Analysis/01.ReStringtieAssemble/{sample}.gtf",
        cov = OUTPUTDIR + "Part05_Expression_Analysis/01.ReStringtieAssembly/{sample}.coverage.cov",
        abu = OUTPUTDIR + "Part05_Expression_Analysis/01.ReStringtieAssembly/{sample}.GeneAbund.txt"
    message:
        "Start to assembly use stringtie."
    log:
        OUTPUTDIR + "AllLogs/Part05_Expression_Analysis/01.ReStringtieAssembly/{sample}.assembly.logs"
    priority:
        50
    threads:
        8
    params:
        opt = "-m 200 -l STRG -a 10 -c 1 -e",
        bal = OUTPUTDIR + "Part05_Expression_Analysis/01.ReStringtieAssembly/Ballgown/{sample}"
    shell:
        """
        stringtie {input.bam} -G {input.gtf} -o {output.gtf} -p {threads} {params.opt} \
        -C {output.cov} -A {output.abu} -b {params.bal}
        """
# Step 02: Get assembled gtf list
rule Part05_Expression_Analysis_02_GetAssembledGtfList:
    input:
        expand(OUTPUTDIR + "Part05_Expression_Analysis/01.ReStringtieAssemble/{sample}.gtf", sample = SAMPLES)
    output:
        lst = OUTPUTDIR + "Part05_Expression_Analysis/02.GetAssembledGtfList/AssembledGtfList.txt"
    threads:
        1
    run:
        with open(output.lst, 'w') as f:
            for gtf in input:
                sample = re.search(r'01\.ReStringtieAssemble/(.*).gtf', gtf).group(1)
                outline = "\t".join((sample, gtf))
                print(outline, file=f)
# Step 03: Get gene and transcripts count matrix
rule Part05_Expression_Analysis_03_GetCountAndTPMMatrix:
    input:
        OUTPUTDIR + "Part05_Expression_Analysis/02.GetAssembledGtfList/AssembledGtfList.txt"    
    output:
        gene = OUTPUTDIR + "Part05_Expression_Analysis/03.GetCountAndTPMMatrix/gene_count_matrix.csv",
        mrna = OUTPUTDIR + "Part05_Expression_Analysis/03.GetCountAndTPMMatrix/transcript_count_matrix.csv",
        tran = OUTPUTDIR + "Part05_Expression_Analysis/03.GetCountAndTPMMatrix/transcript_tpm_matrix.tsv"
    log:
        cnt = OUTPUTDIR + "AllLogs/Part05_Expression_Analysis/03.GetCountAndTPMMatrix/MakeCountMatrix.log",
        tpm = OUTPUTDIR + "AllLogs/Part05_Expression_Analysis/03.GetCountAndTPMMatrix/MakeTPMMatrix.log"
    params:
        "-l 145 -s MSTRG"
    shell:
        """
        prepDE.py -i {input} -g {output.gene} -t {output.mrna} {params} 2> {log.cnt} && \
        perl Scripts/GetTPMFromSringtieGtfList.pl {input} > {output.tran} 2> {log.tpm}
        """
# Step 04: Different Expression Analysis by edgeR
rule Part05_Expression_Analysis_04_DGEbyEdgeR2:
    input:
        gcm = OUTPUTDIR + "Part05_Expression_Analysis/03.GetCountAndTPMMatrix/gene_count_matrix.csv",
        mcm = OUTPUTDIR + "Part05_Expression_Analysis/03.GetCountAndTPMMatrix/transcript_count_matrix.csv",
        cp = COMPARE_PAIRS,
        sg = SAMPLE_GROUPS
    output:
        ok = OUTPUTDIR + "Part05_Expression_Analysis/04.DGEbyEdgeR2/DGEbyEdgeR2.Result.ok"
    log:
        OUTPUTDIR + "AllLogs/Part05_Expression_Analysis/04.DGEbyEdgeR2/DGEbyEdgeR2.log"
    threads:
        8
    params:
        opt = "--foldchange 2 --fdr 0.05",
        out_dir = OUTPUTDIR + "Part05_Expression_Analysis/04.DGEbyEdgeR2/"
    shell:
        """
        source activate r_edger_env && \
        # Rscript Scripts/DGEs.R {params} -t {threads} --matrix {input.gcm} --group {input.sg} --compare {input.cp} -o {params.out_dir} && \
        # Rscript Scripts/DGEs.R {params} -t {threads} -m {input.mcm} -g {input.sg} -c {input.cp} -o {params.out_dir} && \
        echo SUCCESS > {output.ok} && \
        """
#
##################################################################
## ================ Part 06 circRNA Identification ============ ##
##################################################################
#
# Step 01: Map rRNA free reads to genome with bwa-mem
rule Part06_CircRNA_Analysis_01_BWA2Genome:
    input:
        idx = BWA_DNA_INDEX,
        R1 = OUTPUTDIR + "Part01_Preprocess/03.rRNAFreeFastq/{sample}.R1.fq.gz",
        R2 = OUTPUTDIR + "Part01_Preprocess/03.rRNAFreeFastq/{sample}.R2.fq.gz"
    output:
        sam = OUTPUTDIR + "Part06_CircRNA_Analysis/01.BWA2Genome/{sample}.sam"
    log:
        OUTPUTDIR + "AllLogs/Part06_CircRNA_Analysis/01.BWA2Genome/{sample}.bwa_mem.log"
    message:
        "Start to filter rRNA baseed on RNACentral plant rRNA database by bowtie2."
    params:
        "-T 19"    
    threads:
        8    
    shell:
        """
        bwa mem {params} -o {output.sam} -t {threads} {input.idx} {input.R1} {input.R2} 2> {log}
        """
# Step 02: CircRNA identification with CIRI2
rule Part06_CircRNA_Analysis_02_CICR2_Prediction:
    input:
        ref = DNA,
        gtf = GTF,
        sam = OUTPUTDIR + "Part06_CircRNA_Analysis/01.BWA2Genome/{sample}.sam"
    output:
        ciri = OUTPUTDIR + "Part06_CircRNA_Analysis/02.CIRI2_Prediction/{sample}.ciri"
    log:
        OUTPUTDIR + "AllLogs/Part06_CircRNA_Analysis/02.CIRI2_Prediction/{sample}.ciri.log"
    params:
        "-M Mt -Q"
    threads:
        8    
    shell:
        """
        perl /opt/biosoft/CIRI2/CIRI2.pl {params} -T {threads} -I {input.sam} \
        -O {output.ciri} -F {input.ref} -A {input.gtf} --log {log} 
        """        
# Step 03: CircRNA Quantitation
rule Part06_CircRNA_Analysis_03_CircRNA_Quantitation:
    input:
        conf = CIRI_Quant_CFG,
        ciri = OUTPUTDIR + "Part06_CircRNA_Analysis/02.CIRI2_Prediction/{sample}.ciri",
        R1 = OUTPUTDIR + "Part01_Preprocess/03.rRNAFreeFastq/{sample}.R1.fq.gz",
        R2 = OUTPUTDIR + "Part01_Preprocess/03.rRNAFreeFastq/{sample}.R2.fq.gz"
    output:
        gtf = OUTPUTDIR + "Part06_CircRNA_Analysis/03.CircRNA_Quantitation/{sample}/{sample}.gtf"
    log:
        OUTPUTDIR + "AllLogs/Part06_CircRNA_Analysis/03.CircRNA_Quantitation/{sample}.CIRIquant.log"
    params:
        opt = "--tool CIRI2",
        dir = OUTPUTDIR + "Part06_CircRNA_Analysis_03.CircRNA_Quantitation/{sample}",
        perfix = "{sample}",
    threads:
        8
    shell:
        """
        source activate CIRIquant_env && \
        CIRIquant --config {input.cfg} {params.opt} -1 {input.R1} -2 {input.R2} -o {params.dir} \
            -p {params.perfix} -t {threads} --circ {input.ciri} -e {log}
        """
# Step 04: Identify circRNA by find_circ -- 1.mapping
rule Part06_CircRNA_Analysis_04_Bowtie2ToGenome:
    input:
        idx = BOWTIE2_DNA_INDEX,
        R1 = OUTPUTDIR + "Part01_Preprocess/03.rRNAFreeFastq/{sample}.R1.fq.gz",
        R2 = OUTPUTDIR + "Part01_Preprocess/03.rRNAFreeFastq/{sample}.R2.fq.gz"
    output:
        bam  = OUTPUTDIR + "Part06_CircRNA_Analysis/04.Bowtie2ToGenome/{sample}.sorted.bam",
    log:
        OUTPUTDIR + "AllLogs/Part06_CircRNA_Analysis/04.Bowtie2ToGenome/{sample}.align.logs"
    threads:
        8
    params:
        bwt = "-q --very-sensitive --score-min=C,-15,0 --mm",
        sam = "-O bam -@ 4"
    shell:
        """
        bowtie2 {params.bwt} -p {threads} -x {input.idx} -1 {input.R1} -2 {input.R2} 2> {log} \
            | samtools view -hbuS - | samtools sort {params.sam} -o {output.bam}
        """
# Step 05: Identify circRNA by find_circ -- 2.Fetch unmapped read with bowtie2
rule Part06_CircRNA_Analysis_05_FetchUnmappedBam:
    input:
        bam = OUTPUTDIR + "Part06_CircRNA_Analysis/04.Bowtie2ToGenome/{sample}.sorted.bam"
    output:
        bam = OUTPUTDIR + "Part06_CircRNA_Analysis/05.UnmappedBam/{sample}.unmapped.bam"
    threads:
        4        
    shell:
        """
        samtools view -hf4 -@ {threads} {input.bam} | samtools view -@ {threads} -Sb - > {output.bam}
        """
# Step 06: Identify circRNA by find_circ -- 3.Convert bam to qfa
rule Part06_CircRNA_Analysis_06_Bam2Anchors:
    input:
        bam = OUTPUTDIR + "Part06_CircRNA_Analysis/05.UnmappedBam/{sample}.unmapped.bam"
    output:
        fq = OUTPUTDIR + "Part06_CircRNA_Analysis/06.Bam2Anchors/{sample}/unmapped_anchors.fq.gz"
    params:
        DIR = OUTPUTDIR + "Part06_CircRNA_Analysis/06.Bam2Anchors/{sample}"
    run:
        import os
        import subprocess
        if not os.path.exists(params.DIR):
            os.makedirs(params.DIR)

        cmd = ("source activate find_circ_env && unmapped2anchors.py {bam} | "
        " gzip > {fq} && conda deactivate").format(bam=input.bam, fq=output.fq)

        print(cmd)
        subprocess.call(cmd, shell=True)
# Step 07: Identify circRNA by find_circ -- 4.Find circRNA
rule Part06_CircRNA_Analysis_07_FindCircRNA:
    input:
        fq = OUTPUTDIR + "Part06_CircRNA_Analysis/06.Bam2Anchors/{sample}/unmapped_anchors.fq.gz",
        dna = DNA,
        idx = BOWTIE2_DNA_INDEX
    output:
        fa = OUTPUTDIR + "Part06_CircRNA_Analysis/07.FindCircRNA/{sample}/spliced_reads.fa",
        bed = OUTPUTDIR + "Part06_CircRNA_Analysis/07.FindCircRNA/{sample}/spliced_reads.bed",
        stat = OUTPUTDIR + "Part06_CircRNA_Analysis/07.FindCircRNA/{sample}/stat.txt"
    log:
        OUTPUTDIR + "AllLogs/Part06_CircRNA_Analysis/07.FindCircRNA/{sample}.align.logs"
    threads:
        8
    params:
        bwt = "--score-min=C,-15,0 --reorder --mm -q",
        fic = "--prefix=zma_{sample}_  --name={sample}",
    run:
        import subprocess

        cmd = ("source activate find_circ_env && bowtie2 {bwt} -p {t} -U {fq} -x {idx} 2> {log} | "
        "find_circ.py --genome={dna} {fic} --stats={stat} --reads={fa} > {bed} && conda deactivate").format(bwt=params.bwt, 
        t=threads, fq=input.fq, idx=input.idx, log=log, dna=input.dna, fic=params.fic, stat=output.stat, fa=output.fa, bed=output.bed)

        print(cmd)
        subprocess.call(cmd, shell=True)
# Step 08: Identify circRNA by find_circ -- 5.Merge all samples bed
rule Part06_CircRNA_Analysis_08_MergeAllSamplesBed:
    input:
        expand(OUTPUTDIR + "Part06_CircRNA_Analysis/07.FindCircRNA/{sample}/spliced_reads.bed", sample = SAMPLES)
    output:
        bed = OUTPUTDIR + "Part06_CircRNA_Analysis/08.MergeAllSamplesBed/merged_spliced_reads.bed",
        stat = OUTPUTDIR + "Part06_CircRNA_Analysis/08.MergeAllSamplesBed/merged_stat.txt"
    run:
        import subprocess

        cmd = ("source activate find_circ_env && merge_bed.py {i} -s {s} > {bed}"
            ).format(i=input, s=output.stat, bed=output.bed)
        
        print(cmd)
        subprocess.call(cmd, shell=True)
# Step 09: Identify circRNA by find_circ -- 6.Fetch Good circRNA
rule Part06_CircRNA_Analysis_09_FetchFinalCircRNA:
    input:
        OUTPUTDIR + "Part06_CircRNA_Analysis/08.MergeAllSamplesBed/merged_spliced_reads.bed"
    output:
        OUTPUTDIR + "Part06_CircRNA_Analysis/09.FinalCircRNA/circ_candidates.bed"
    run:
        import subprocess
        cmd = ("source activate find_circ_env && grep CIRCULAR {i} | awk '$5>=2' "
                "grep UNAMBIGUOUS_BP | grep ANCHOR_UNIQUE | maxlength.py 100000 > {o}"
                ).format(i=input, o=output)
        
        print(cmd)
        subprocess.call(cmd)
#
##################################################################
## ================ Part 07 Final Analysis Report ============= ##
##################################################################
#
# Report 01: Fastq Filter Result
    # rule Report_01_FastqFilterState1:
    #     input:
    #         expand( OUTPUTDIR + "Step01.FastqFilter/{sample}/{sample}.json", sample=SAMPLES )
    #     output:
    #         lst = OUTPUTDIR + "Report/S01.FastqFilter.jsonlist.txt"
    #     run:
    #         with open(output.lst, 'w') as jo:
    #             for filename in input:
    #                 print(filename, file=jo)

    # ## -------- XXXXXXXXXXXXXXXXXXXXXXXXXXX --------------------
    # rule Report_01_FastqFilterState2:
    #     input:
    #         OUTPUTDIR + "Report/S01.FastqFilter.jsonlist.txt"
    #     output:
    #         tsv = OUTPUTDIR + "Report/S01.FastqFilter-State.tsv"
    #     shell:
    #         """
    #         source activate data_env && \
    #         python Scripts/GetFastqFilterState.py {input} {output}
    #         """
    # ## -------- Report 02: rRNA Filter Result --------
    # ## -------- Report 03: Genome alianment Result --------
    # rule Report_03_ReadDistribution:
    #     input:
    #         bed = BED,
    #         bam = OUTPUTDIR + "Step03.Hisat2Genome/{sample}.bam"        
    #     output:
    #         OUTPUTDIR + "Report/S03.ReadDistribution/{sample}.state.tsv"
    #     log:
    #         OUTPUTDIR + "logs/Report/S03.GenomeAlianmentStatebyRseQC.{sample}.log"
    #     params:
    #         prx = OUTPUTDIR + "Report/S03.ReadDistribution/",
    #         log_dir = OUTPUTDIR + "logs/Report/"
    #     shell:
    #         """
    #         source activate py3.7 && \
    #         if [ ! -d {params.prx} ]; then mkdir -p {params.prx}; fi && \
    #         if [ ! -d {params.log_dir} ]; then mkdir -p {params.log_dir}; fi && \
    #         read_distribution.py -i {input.bam} -r {input.bed} > {output} 2> {log} && \
    #         conda deactivate
    #         """


    # ## -------- Report 04: Genome guid assembly Result --------
    # ## -------- Report 05: Genome guid assembly Result --------
    # ## -------- Report 06: Genome guid assembly Result --------
    # ## -------- Report 07: Genome guid assembly Result --------
    # ## -------- Report 08: Genome guid assembly Result --------
    # ## -------- Report 09: Genome guid assembly Result --------
    # ## -------- Report 10: Genome guid assembly Result --------
    # ## -------- Report 00: Output html report --------
#