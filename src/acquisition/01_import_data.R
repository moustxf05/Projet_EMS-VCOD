# 1. On force R à se placer dans le dossier de ton projet
# (Le tilde ~ remplace /home/ton_nom/...)
setwd("~/2annee/Semestre2/Projet_EMS-VCOD")

# 2. On vérifie qu'on est au bon endroit
print(paste("Dossier actuel :", getwd()))

# 3. On recharge la librairie et on cherche les fichiers
library(seqinr)
fichiers_fasta <- list.files(path = "data/premiere_sequence", pattern = "\\.fasta$", full.names = TRUE)

# 4. Verdict ?
if(length(fichiers_fasta) > 0) {
  print(paste("SUCCÈS !", length(fichiers_fasta), "fichiers trouvés."))
  
  # --- Si succès, on lance l'importation tout de suite ---
  toutes_les_donnees <- list()
  
  for (fichier in fichiers_fasta) {
    alignement <- read.alignment(file = fichier, format = "fasta")
    infos <- strsplit(basename(fichier), "_")[[1]]
    
    df_temp <- data.frame(
      id = alignement$nam,
      sequence_brute = unlist(alignement$seq),
      pays = infos[3],
      lot = sub(".fasta", "", infos[4]),
      stringsAsFactors = FALSE
    )
    toutes_les_donnees[[length(toutes_les_donnees) + 1]] <- df_temp
  }
  
  global_data <- do.call(rbind, toutes_les_donnees)
  
  # Découpage (nettoyage)
  decouper_sequence <- function(seq_string) { return(strsplit(seq_string, split = "")[[1]]) }
  global_data$sequence_liste <- lapply(global_data$sequence_brute, decouper_sequence)
  
  print("Importation terminée. Voici un aperçu :")
  print(table(global_data$pays))
  
} else {
  print("ERREUR : Toujours 0 fichier. Vérifie que le dossier 'data' contient bien les fichiers .fasta")
  print("Contenu du dossier actuel :")
  print(list.files())
}
