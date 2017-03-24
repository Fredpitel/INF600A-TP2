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
  TITRE = %r{}
  NOMBRE = %r{}
  PREALABLES = %r{}

  # Motif pour un cours complet
  COURS = %r{}
end
