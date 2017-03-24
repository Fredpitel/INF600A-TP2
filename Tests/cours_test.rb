require_relative 'test_helper'
require_relative '../cours'
require_relative '../cours-texte'

describe Cours do
  let(:erreurs_possibles) { [ArgumentError, RuntimeError, StandardError] }

  let(:inf1120) { Cours.new( :INF1120, "Programmation I", 3 ) }
  let(:inf2120) { Cours.new( :INF2120, "Programmation II", 3, :INF1120 ) }
  let(:mat3143) { Cours.new( :MAT3143, "Methodes formelles", 3, :INF1120, :INF2120, actif: false ) }

  describe ".new" do
    it_ "cree un cours sans prealable avec les attributs appropries" do
      inf1120.sigle.must_equal :INF1120
      inf1120.titre.must_equal 'Programmation I'
      inf1120.nb_credits.must_equal 3
      assert inf1120.actif?
      inf1120.prealables.must_be_empty
    end

    it_ "cree un cours avec des prealables" do
      inf2120.prealables.must_equal [:INF1120]
    end

    it_ "cree un cours inactif" do
      mat3143.sigle.must_equal :MAT3143
      mat3143.titre.must_equal 'Methodes formelles'
      mat3143.nb_credits.must_equal 3
      refute mat3143.actif?
      mat3143.prealables.must_equal [:INF1120, :INF2120]
    end

  end

  describe "#<=>" do
    it_ "retourne 0 par rapport a lui-meme" do
      (inf1120 <=> inf1120).must_equal 0
    end

    it_ "retourne -1 par rapport a un sigle plus grand" do
      (inf1120 <=> inf2120).must_equal( -1 )
    end

    it_ "retourne +1 par rapport a un sigle plus petit_" do
      inf2120 = Cours.new( :INF0000, "Programmation 0", 3 )
      (inf1120 <=> inf2120).must_equal 1
    end
  end

  describe "#to_s -- tests_base" do
    it_ "genere par defaut une forme simple avec des guillemets pour titre" do
      inf1120.to_s.must_equal 'INF1120 "Programmation I" ()'
    end

    it_ "genere par defaut une forme simple avec ? pour cours inactif" do
      mat3143.to_s.must_equal 'MAT3143? "Methodes formelles" (INF1120:INF2120)'
    end

    it_ "genere par defaut une forme simple avec des guillemets pour titre et avec prealables" do
      inf2120.to_s.must_equal 'INF2120 "Programmation II" (INF1120)'
    end

    it_ "produit_ la chaine indiquee quand aucun format n'est specifie" do
      inf1120.to_s( "ABC" ).must_equal 'ABC'
    end

    it_ "produit_ les bons elements, meme lorsqu'un it_em apparait_ plusieurs" do
      inf1120.to_s( "%S %S %C %T %S" ).must_equal 'INF1120 INF1120 3 Programmation I INF1120'
    end

    it_ "inclut les diverses chaines qui ne sont pas des formats" do
      inf1120.to_s( "titre = '%T' => %S (%C)" ).must_equal "titre = 'Programmation I' => INF1120 (3)"
    end

    it_ "produit par defaut le meme resultat que '%S \"%-10T\" (%P)'" do
      inf1120.to_s( '%S "%-10T" (%P)' ).must_equal inf1120.to_s
    end
  end

  describe "#to_s -- tests_intermediaire" do
    it_ "traite les justifications et la largeur maximum", :intermediaire do
      inf1120.to_s( "%9S:%-9S:%.9S" ).must_equal '  INF1120:INF1120  :INF1120'
    end

    it_ "genere une erreur quand une specification de champ non valide est indiquee", :intermediaire do
      assert_raises( *erreurs_possibles ) { inf1120.to_s( "xxx %N %s %T" ) }
      assert_raises( *erreurs_possibles ) { inf1120.to_s( "xxx %d %T %T" ) }
    end
  end

  describe "#to_s -- tests_intermediaire" do
    it_ "traite la specification de separateur de prealables par defaut", :intermediaire do
      mat3143.to_s( "(%P)" ).must_equal '(INF1120:INF2120)'
    end

    it_ "traite la specification de separateur de prealables explicite", :intermediaire do
      mat3143.to_s( "%P", " " ).must_equal 'INF1120 INF2120'
    end
  end

  describe "#to_s" do
    it_ "assure que le format n'est pas modifie par une utilisation", :intermediaire do
      format = "%T => %S"
      inf1120.to_s( format ).must_equal 'Programmation I => INF1120'
      format.must_equal "%T => %S"
    end
  end

  describe "#activer/desactiver" do
    it_ "est actif lorsqu'on le cree" do
      assert inf1120.actif?
    end

    it_ "devient inactif si on le desactive explicit_ement" do
      inf1120.desactiver

      refute inf1120.actif?
    end

    it_ "redevient actif si on l'active apres l'avoir desactive" do
      inf1120.desactiver
      inf1120.activer

      assert inf1120.actif?
    end
  end
end
