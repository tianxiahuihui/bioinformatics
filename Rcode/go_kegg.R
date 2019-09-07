

enrich <- function(entrezIDs, orgDbName="org.Hs.eg.db", pvalueCutoff=.01){
	require(orgDbName, character.only=TRUE)
	require("GSEABase")
	require("GOstats")
	require("Category")
	goAnn <- get(gsub(".db", "GO", orgDbName))
	universe <- Lkeys(goAnn)
	onto <- c("BP", "MF", "CC")
	res <- lapply(onto, function(.onto){
		param <- new('GOHyperGParams',
					 geneIds= entrezIDs,
					 universeGeneIds=universe,
					 annotation=orgDbName,
					 ontology=.onto,
					 pvalueCutoff=pvalueCutoff,
					 conditional=FALSE,
					 testDirection="over")
		over <- hyperGTest(param)
		glist <- geneIdsByCategory(over)
		glist <- sapply(glist, function(.ids) {
			.sym <- mget(.ids, envir=get(gsub(".db", "SYMBOL", orgDbName)), ifnotfound=NA)
			.sym[is.na(.sym)] <- .ids[is.na(.sym)]
			paste(.sym, collapse=";")
		})
		summary <- summary(over)
		if(nrow(summary)>1) summary$Symbols <- glist[as.character(summary[, 1])]
		summary
	})
	names(res) <- onto
	keggAnn <- get(gsub(".db", "PATH", orgDbName))
	universe <- Lkeys(keggAnn)
	param <- new("KEGGHyperGParams",
				 geneIds=entrezIDs,
				 universeGeneIds=universe,
				 annotation=orgDbName,
				 categoryName="KEGG",
				 pvalueCutoff=pvalueCutoff,
				 testDirection="over")
	over <- hyperGTest(param)
	kegg <- summary(over)
	glist <- geneIdsByCategory(over)
	glist <- sapply(glist, function(.ids) {
		.sym <- mget(.ids, envir=get(gsub(".db", "SYMBOL", orgDbName)), ifnotfound=NA)
		.sym[is.na(.sym)] <- .ids[is.na(.sym)]
		paste(.sym, collapse=";")
	})
	kegg$Symbols <- glist[as.character(kegg$KEGGID)]
	res[["kegg"]] <- kegg
	res
}
 
go <- enrich(entrezIDs, "org.Hs.eg.db", .05)
