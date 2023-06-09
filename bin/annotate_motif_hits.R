
###########################################################################
## Annotate FIMO motif hits using annotated enhancer file
###########################################################################

library(tidyverse)
library(stringr)
library(optparse)

# Read in command line opts
option_list <- list(
    make_option(c("-n", "--gene_name_col"), action = "store", type = "character", help = "Column name in gtf containing gene names", default = 'gene_name'),
    make_option(c("-i", "--gene_id_col"), action = "store", type = "character", help = "Column name in gtf containing gene ids", default = 'gene_id'),
    make_option(c("-p", "--motif_tsv"), action = "store", type = "character", help = "Path to motif tsv output from memesuite"),
    make_option(c("-g", "--annotated_peaks"), action = "store", type = "character", help = "Path to annotated peaks file"))

opt_parser = OptionParser(option_list = option_list)
opt <- parse_args(opt_parser)

motif_matches <- read.csv(list.files(opt$motif_tsv, full.names = TRUE, pattern = "*.tsv"), sep='\t', comment.char = "#", stringsAsFactors=FALSE)
# motif_matches <- read.csv(list.files('/temp/results/memesuite_fimo/fimo_output', full.names = TRUE, pattern = "*.tsv"), sep='\t', comment.char = "#", stringsAsFactors=FALSE)

motif_matches <- motif_matches %>% separate(sequence_name, into=c("peakid", "coordinates"), sep="::", convert = TRUE)

# Load annotated peaks
annotated_peaks <- read.delim(opt$annotated_peaks, stringsAsFactors=FALSE)
# annotated_peaks <- read.delim('/temp/results/annotate_peaks_to_gtf/annotated_peaks.tsv', stringsAsFactors=FALSE)


# Extract gene id for peaks with motif matches
motif_matches[['gene_id']] <- annotated_peaks[match(motif_matches$peakid, annotated_peaks$peakid), opt$gene_id_col]
motif_matches[['gene_name']] <- annotated_peaks[match(motif_matches$peakid, annotated_peaks$peakid), opt$gene_name_col]

if(!opt$gene_id_col %in% colnames(annotated_peaks)){stop(paste(opt$gene_id_col, ' does not match gene id column in peak file'))}
if(!opt$gene_name_col %in% colnames(annotated_peaks)){stop(paste(opt$gene_name_col, ' does not match gene name column in peak file'))}

# motif_matches[['gene_id']] <- annotated_peaks[match(motif_matches$peakid, annotated_peaks$peakid), 'gene_id']
# motif_matches[['gene_name']] <- annotated_peaks[match(motif_matches$peakid, annotated_peaks$peakid), 'gene_name']

motif_matches <- motif_matches %>% arrange(motif_alt_id)

write.table(motif_matches, file = './annotated_motifs.tsv', row.names = FALSE, col.names = TRUE, quote = FALSE, sep = '\t')