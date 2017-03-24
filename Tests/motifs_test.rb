require_relative 'test_helper'
require_relative '../motifs'

describe Motifs do
  describe Motifs::SIGLE do
    it_ "matche un sigle correct" do
      "INF1130".must_match Motifs::SIGLE
    end

    it_ "ne matche pas un sigle trop court" do
      "INF130".wont_match Motifs::SIGLE
    end

    it_ "ne matche pas un sigle trop long" do
      "INF1103X".wont_match Motifs::SIGLE
    end
  end

  describe Motifs::TITRE do
    it_ "matche un titre avec guillemets" do
      '"Mathematiques pour informaticien"'.must_match Motifs::TITRE
    end

    it_ "matche un titre avec apostrophes" do
      "'Mathematiques pour informaticien'".must_match Motifs::TITRE
    end

    it_ "matche un titre avec plein de caracterees quelconques" do
      "'Programmation 1: Methodes + classes!'".must_match Motifs::TITRE
    end

    it_ "matche un titre avec guillemets qui contient un guillemet" do
      '"Mathematiques pour l\"informatique"'.must_match Motifs::TITRE
    end

    it_ "matche un titre avec apostrophes qui contient un apostrophe" do
      "'Mathematiques pour l\'informatique'".must_match Motifs::TITRE
    end

    it_ "matche un titre sans guillemets ou apostrophes" do
      "Mathematiques pour informaticien".must_match Motifs::TITRE
    end
  end

  describe Motifs::NOMBRE do
    it_ "matche un nombre simple" do
      "3".must_match Motifs::NOMBRE
    end

    it_ "matche un nombre plus complexe" do
      "9".must_match Motifs::NOMBRE
    end

    it_ "ne matche pas un identificateur" do
      "zero".wont_match Motifs::NOMBRE
    end

    it_ "matche zero" do
      "0".must_match Motifs::NOMBRE
    end
  end

  describe Motifs::PREALABLES do
    it_ "ne matche pas 0 prealable" do
      "".wont_match Motifs::PREALABLES
    end

    it_ "matche 1 prealable" do
      "INF1120".must_match Motifs::PREALABLES
    end

    it_ "matche 2 prealables" do
      "INF1120 INF1130".must_match Motifs::PREALABLES
    end

    it_ "matche plusieurs prealables" do
      "INF1120 INF1130   INF3104      INF9999".must_match Motifs::PREALABLES
    end

    it_ "ne matche pas si sigle incorrect" do
      "INF110".wont_match Motifs::PREALABLES
    end
  end

  describe Motifs::COURS do
    it_ "matche un cours complet sans prealable" do
      "INF1120 'Programmation I' 3".must_match Motifs::COURS
    end

    it_ "matche un cours complet avec 1 prealable" do
      "INF2120 'Programmation II'   3     INF1120".must_match Motifs::COURS
    end

    it_ "matche un cours complet avec plusieurs prealable" do
      'INF3135 "Construction et maintenance"   3     INF1120 INF2120    INF1130'.must_match Motifs::COURS
    end

    it_ "ne matche pas si des elements en trop au debut" do
      'xx INF3135 "Construction et maintenance"   3     INF1120 INF2120    INF1130'.wont_match Motifs::COURS
    end

    it_ "ne matche pas si des elements en trop a la fin" do
      'INF3135 "Construction et maintenance"   3    INF1120 INF2120  xxx'.wont_match Motifs::COURS
    end
  end
end
