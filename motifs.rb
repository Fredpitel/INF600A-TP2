require_relative 'cours-texte'
#
# Module qui regroupe des constantes definissant les divers motifs
# pour identifier les champs d'un cours.
#
module Motifs
  # Motifs mots representant sigle, titre, nommbre (de credits) et prealables.
  #
  # Rappel: les deux facons suivantes permettent de definir un objet Rexexp.
  #   %r{...}
  #   /.../

  SIGLE =  %r{\b[A-Z]{3}[0-9]{3}[A-Z0-9]\b}
  TITRE = %r{\b[a-zA-Z]+\b}
  NOMBRE = %r{\b[0-9]+\b}
  PREALABLES = %r{\b(SIGLECoursTexte::SEPARATEUR_PREALABLES)*SIGLE\b}

  # Motif pour un cours complet
  COURS = %r{\bSIGLECoursTexte::SEP TITRECoursTexte::SEP NOMBRECoursTexte::SEP (PREALABLES)*\b}
end
