#
# Module qui specifie les details du format, textuel, pour la base de
# donnees, notamment, les separateurs, le format exact pour la
# lecture/ecriture dans le fichier.
#

module CoursTexte
  # Separateur pour les champs d'un enregistrement specificant un cours.
  SEPARATEUR = ','
  SEP = SEPARATEUR  # Un alias pour alleger les expr. reg.

  # Separateur pour les prealables d'un cours.
  SEPARATEUR_PREALABLES = ':'

  # Etat d'un cours
  ACTIF  = 'ACTIF'
  INACTIF  = 'INACTIF'


  # Methode pour creer un objet Cours a partir d'une ligne lue dans le
  # depot de donnees.
  def self.creer_cours( ligne )
    sigle, titre, nb_credits, prealables, actif = ligne.chomp.split(SEP)
    Cours.new( sigle.to_sym,
               titre,
               nb_credits.to_i,
               *prealables.split(SEPARATEUR_PREALABLES).map(&:to_sym),
               actif: actif == ACTIF )
  end

  # Methode pour sauvegarder un objet Cours dans le depot de donnees.
  def self.sauver_cours( fich, cours )
    actif = cours.actif? ? ACTIF : INACTIF
    prealables = cours.prealables.join(CoursTexte::SEPARATEUR_PREALABLES)
    fich.puts [cours.sigle, cours.titre, cours.nb_credits, prealables, actif].join(CoursTexte::SEP)
  end
end
