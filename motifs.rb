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

  SIGLE =  /\b[A-Z]{3}[0-9]{4}\b/
  TITRE = /\b[\w\s]+\b/
  NOMBRE = /\b[0-9]+\b/
  PREALABLES = /\b(#{SIGLE} *)+\b/

  # Motif pour un cours complet
  COURS = /^#{SIGLE} +('|")#{TITRE}('|") +#{NOMBRE}( +#{PREALABLES})?$/
end
