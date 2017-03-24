require_relative 'dbc'
require_relative 'motifs'
require_relative 'cours-texte'
#
# Objet pour modeliser un cours.
#
# Tous les champs sont immuables (non modifiables) a l'exception du
# champ qui indique si le cours est actif ou non.
#
class Cours
  include Comparable

  attr_reader :sigle
  attr_reader :titre
  attr_reader :nb_credits
  attr_reader :prealables
  attr_accessor :actif

  def initialize( sigle, titre, nb_credits, *prealables, actif: true )
    DBC.require( sigle.kind_of?(Symbol) && /^#{Motifs::SIGLE}$/ =~ sigle,
                 "Sigle incorrect: #{sigle}!?" )
    DBC.require( !titre.strip.empty?,
                 "Titre vide: '#{titre}'" )
    DBC.require( nb_credits.to_i > 0,
                 "Nb. credits invalides: #{nb_credits}!?" )
	  DBC.require( prealables.map {|p| /^#{Motifs::PREALABLES}$/ =~ p} ,
				         "Prealables incorrects: #{prealables}!?" )
    DBC.require( actif.kind_of?(TrueClass) || actif.kind_of?(FalseClass),
                 "Actif incorrect, doit etre true ou false: #{actif}!?" )

    @sigle, @titre, @nb_credits, @prealables, @actif = sigle, titre, nb_credits, prealables, actif
  end

  #
  # Formate un cours selon les indications specifiees par le_format:
  #   - %S: Sigle du cours
  #   - %T: Titre du cours
  #   - %C: Nombre de credits du cours
  #   - %P: Prealables du cours
  #   - %A: Cours actif ou non?
  #
  # Des indications de largeur, justification, etc. peuvent aussi etre
  # specifiees, par exemple, %-10T, %-.10T, etc.
  #
  def to_s( le_format = nil, separateur_prealables = CoursTexte::SEPARATEUR_PREALABLES )
    # Format simple par defaut, pour les cas de tests de base.a
    if le_format.nil?
      return format("%s%s \"%-10s\" (%s)",
                    @sigle,
                    @actif? "" : "?",
                    @titre,
                    @prealables.join(separateur_prealables))
    else
      chaine_formatee = le_format
	    chaine_formatee = chaine_formatee.gsub("%S", @sigle.to_s)
	    chaine_formatee = chaine_formatee.gsub("%T", @titre.to_s)
	    chaine_formatee = chaine_formatee.gsub("%C", @nb_credits.to_s)
	    return chaine_formatee.gsub("%P", @prealables.join(CoursTexte::SEPARATEUR_PREALABLES).to_s)
	  end

    fail "Cas non traite: to_s( #{le_format}, #{separateur_prealables} )"
  end


  #
  # Ordonne les cours selon le sigle.
  #
  def <=>( autre )
    @sigle <=> autre.sigle
  end

  #
  # Rend un cours inactif.
  #
  def desactiver
    DBC.require( actif?, "Cours pas actif: #{self}" )

    @actif = false
  end

  #
  # Rend un cours actif.
  #
  def activer
    DBC.require( !actif?, "Cours deja actif: #{self}" )

    @actif = true
  end

  #
  # Determine si le cours est actif ou non.
  #
  def actif?
    @actif == true
  end
end
