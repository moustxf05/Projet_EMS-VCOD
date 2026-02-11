# -----------------------------------------------------------------------------
# MODULE 1 : IMPORTATION ET NETTOYAGE
# Objectif : Charger les fichiers .fasta et préparer les séquences
# -----------------------------------------------------------------------------

# Vérification et chargement du package
if (!require("seqinr")) install.packages("seqinr")
library(seqinr)

# --- 1. IMPORTATION AUTOMATISÉE ---

# Lister tous les fichiers .fasta dans le dossier data
# (Assure-toi que le dossier 'data' est bien au même niveau que le dossier 'scripts')
fichiers_fasta <- list.files(path = "../data", pattern = "\\.fasta$", full.names = TRUE)

# Si ton script est à la racine du projet, utilise : path = "data"
# Si ton script est dans un dossier 'scripts', utilise : path = "../data"

print(paste("Fichiers trouvés :", length(fichiers_fasta)))

# Initialisation de la liste de stockage
toutes_les_donnees <- list()

# Boucle de lecture
for (fichier in fichiers_fasta) {
  
  # Lecture via seqinr
  alignement <- read.alignment(file = fichier, format = "fasta")
  
  # Extraction métadonnées via le nom du fichier (ex: hiv_db_FR_0.fasta)
  nom_fichier <- basename(fichier)
  infos <- strsplit(nom_fichier, "_")[[1]]
  pays <- infos[3] # ex: FR
  lot <- sub(".fasta", "", infos[4]) # ex: 0
  
  # Création du data.frame temporaire
  df_temp <- data.frame(
    id = alignement$nam,
    sequence_brute = unlist(alignement$seq),
    pays = pays,
    lot = lot,
    source = nom_fichier,
    stringsAsFactors = FALSE
  )
  
  # Ajout à la liste
  toutes_les_donnees[[length(toutes_les_donnees) + 1]] <- df_temp
}

# Fusion en un seul tableau
global_data <- do.call(rbind, toutes_les_donnees)

# --- 2. FORMATAGE ET NETTOYAGE ---

# Fonction pour découper la chaîne de caractères (le fameux strsplit demandé par Thomas)
decouper_sequence <- function(seq_string) {
  return(strsplit(seq_string, split = "")[[1]])
}

# On applique la fonction sur chaque ligne
# Cela crée une colonne 'sequence_liste' qui contient les vecteurs de nucléotides
global_data$sequence_liste <- lapply(global_data$sequence_brute, decouper_sequence)

# --- 3. VÉRIFICATION ---
print("--- Résumé des données importées ---")
print(table(global_data$pays)) # Combien de séquences par pays ?
print(head(global_data))