require_relative 'test_helper'
require_relative '../cours-texte'

describe "GestionAcademique" do
  let(:bd)  { '.cours.txt' }
  let(:separateur)  { CoursTexte::SEPARATEUR }
  let(:separateur_prealables)  { CoursTexte::SEPARATEUR_PREALABLES }

  describe "ajouter" do
    it_ "ajoute dans un fichier vide" do
      nouveau_contenu = avec_fichier bd, [], :conserver do
        execute_sans_sortie_ou_erreur do
          ga( 'ajouter INF1120 "Programmation I" 3' )
        end
      end

      nouveau_contenu.size.must_equal 1
      nouveau_contenu.first.must_equal [:INF1120, 'Programmation I', 3, '', CoursTexte::ACTIF].join(separateur)
      FileUtils.rm_f bd
    end

    it_ "signale une erreur lorsque depot inexistant", :intermediaire do
      FileUtils.rm_f bd
      genere_erreur( /fichier.*[.]cours.txt.*existe pas/ ) do
        ga( 'ajouter INF120 "Programmation I" 3 INF0000 XXX' )
      end
    end

    it_ "signale une erreur lorsque le sigle est invalide", :intermediaire do
      avec_fichier bd, [] do
        genere_erreur( /Sigle.*incorrect/ ) do
          ga( 'ajouter INF120 "Programmation I" 3 INF0000 XXX' )
        end
      end
    end

    it_ "signale une erreur lorsqu'un prealable est invalide au niveau du sigle", :intermediaire do
      avec_fichier bd, [] do
        genere_erreur( /Sigle.*incorrect/ ) do
          ga( 'ajouter INF1120 "Programmation I" 3 IF0000' )
        end
      end
    end

    it_ "signale une erreur lorsqu'un prealable est invalide parce qu'inexistant", :intermediaire do
      avec_fichier bd, [] do
        genere_erreur( /Prealable.*invalide/ ) do
          ga( 'ajouter INF1120 "Programmation I" 3 INF1000' )
        end
      end
    end

    it_ "signale une erreur lorsqu'un prealable est invalide parce qu'inactif", :intermediaire do
      avec_fichier bd, [] do
        genere_erreur( /Prealable.*invalide/ ) do
          ga( 'ajouter INF1120 "Programmation I" 3 INF3143' )
        end
      end
    end

    context "banque de cours avec plusieurs cours" do
      let(:lignes) { IO.readlines("Tests/cours.txt.5+1") }

      it_ "ajoute un cours s'il n'existe pas" do
        sigle = 'INF3143'
        titre = 'Modelisation et specification formelle'
        nb_credits = '3'
        prealables = 'INF1130 INF2120'

        nouveau_contenu = avec_fichier bd, lignes, :conserver do
          execute_sans_sortie_ou_erreur do
            ga( "ajouter #{sigle} \"#{titre}\" #{nb_credits} #{prealables}" )
          end
        end

        nouveau_contenu.last
          .must_equal [sigle, titre, nb_credits, prealables.gsub(/ /, separateur_prealables), CoursTexte::ACTIF].join(separateur)

        FileUtils.rm_f bd
      end


      it_ "signale une erreur lorsqu'un prealable est incorrect", :intermediaire do
        avec_fichier bd, [] do
          genere_erreur( /Prealable.*invalide/ ) do
            ga( 'ajouter INF2160 "Paradigmes de programmation" 3 INF2120 INF200' )
          end
        end
      end

      it_ "signale une erreur lorsqu'un prealable est invalide parce qu'inexistant", :intermediaire do
        avec_fichier bd, [] do
          genere_erreur( /Prealable.*invalide/ ) do
            ga( 'ajouter INF2160 "Paradigmes de programmation" 3 INF2120 INF2100' )
          end
        end
      end

      it_ "signale une erreur lorsqu'le cours existe deja", :intermediaire_ do
        avec_fichier bd, lignes do
          genere_erreur( /meme sigle existe/ ) do
            ga( 'ajouter INF1130 "Mathematiques" 3' )
          end
        end
      end
    end

    context "banque de cours autre que celui par defaut" do
      let(:lignes) { IO.readlines("Tests/cours.txt.5+1") }
      let(:fichier) { '.foo.txt' }

      it_ "signale une erreur lorsque le depot est inexistant", :intermediaire do
        FileUtils.rm_f fichier
        genere_erreur( /fichier.*#{fichier}.*existe pas/ ) do
          ga( "--depot=#{fichier} ajouter INF120 'Programmation I' 3 INF0000 XXX" )
        end
      end

      it_ "ajoute un cours lorsqu'il n'existe pas", :intermediaire do
        sigle = 'INF3143'
        titre = 'Modelisation et specification formelle'
        nb_credits = '3'
        prealables = 'INF1130 INF2120'

        nouveau_contenu = avec_fichier fichier, lignes, :conserver do
          execute_sans_sortie_ou_erreur do
            ga( "--depot=#{fichier} ajouter #{sigle} \"#{titre}\" #{nb_credits} #{prealables}" )
          end
        end

        nouveau_contenu.last
          .must_equal [sigle, titre, nb_credits, prealables.gsub(/ /, separateur_prealables), CoursTexte::ACTIF].join(separateur)

        FileUtils.rm_f fichier
      end
    end
  end

  context "ajout de cours specifie sur stdin" do
    let(:lignes) { IO.readlines("Tests/cours.txt.5+1") }

    it_ "ajoute un cours sans prealable lorsqu'il n'existe pas", :avance do
      sigle = 'INF1000'
      titre = "Introduction a l'informatique"
      nb_credits = '3'

      avec_fichier 'data.txt', ["  #{sigle}   \"#{titre}\"  #{nb_credits}"] do
        nouveau_contenu = avec_fichier bd, lignes, :conserver do
          execute_sans_sortie_ou_erreur do
            ga( "ajouter < data.txt" )
          end
        end

        nouveau_contenu.last
          .must_equal [sigle, titre, nb_credits, '', CoursTexte::ACTIF].join(separateur)
      end

      FileUtils.rm_f bd
    end

    it_ "ajoute un cours avec des prealables lorsqu'il n'existe pas", :avance do
      sigle = 'INF3143'
      titre = 'Modelisation et specification formelle'
      nb_credits = '3'
      prealables = '  INF1130  INF2120 '

      prealables_finaux = prealables.strip.squeeze(' ').gsub(/ /, separateur_prealables)

      avec_fichier 'data.txt', ["  #{sigle}   \"#{titre}\"  #{nb_credits} #{prealables} "] do
        nouveau_contenu = avec_fichier bd, lignes, :conserver do
          execute_sans_sortie_ou_erreur do
            ga( "ajouter < data.txt" )
          end
        end

        nouveau_contenu.last
          .must_equal [sigle, titre, nb_credits, prealables_finaux, CoursTexte::ACTIF].join(separateur)
      end

      FileUtils.rm_f bd
    end

    it_ "ajoute plusieurs cours lorsqu'ils n'existent pas", :avance do
      sigle1 = 'INF3143'
      titre1 = 'Modelisation et specification formelle'
      nb_credits1 = '3'
      prealables1 = '  INF1130  INF2120 '
      prealables1_finaux = prealables1.strip.squeeze(' ').gsub(/ /, separateur_prealables)

      sigle2 = 'INF600A'
      titre2 = 'Langages de script'
      nb_credits2 = '3'
      prealables2 = '  INF3143  '
      prealables2_finaux = prealables2.strip.squeeze(' ').gsub(/ /, separateur_prealables)

      avec_fichier 'data.txt', ["#{sigle1} \"#{titre1}\" #{nb_credits1} #{prealables1}",
                                "",
                                "#{sigle2}    '#{titre2}' #{nb_credits2} #{prealables2}",
                                "      ",
                               ] do
        nouveau_contenu = avec_fichier bd, lignes, :conserver do
          execute_sans_sortie_ou_erreur do
            ga( "ajouter < data.txt" )
          end
        end

        nouveau_contenu[-2]
          .must_equal [sigle1, titre1, nb_credits1, prealables1_finaux, CoursTexte::ACTIF].join(separateur)

        nouveau_contenu[-1]
          .must_equal [sigle2, titre2, nb_credits2, prealables2_finaux, CoursTexte::ACTIF].join(separateur)
      end

      FileUtils.rm_f bd
    end

    it_ "n'ajoute rien si un des cours specifie a des erreurs", :avance do
      sigle1 = 'INF3143'
      titre1 = 'Modelisation et specification formelle'
      nb_credits1 = '3'
      prealables1 = '  INF1130  INF2120 '

      sigle2 = 'INF600A'
      titre2 = 'Langages de script'
      nb_credits2 = '3'
      prealables2 = '  INF3103  '

      avec_fichier 'data.txt', ["#{sigle1} \"#{titre1}\" #{nb_credits1} #{prealables1}",
                                "",
                                "#{sigle2}    '#{titre2}' #{nb_credits2} #{prealables2}",
                                "      ",
                               ] do
        avec_fichier bd, lignes, :conserver do
          FileUtils.cp bd, "#{bd}.avant"
          genere_erreur( /Prealable invalide.*INF3103/ ) do
            ga( "ajouter < data.txt" )
          end
        end

        %x{cmp #{bd} #{bd}.avant; echo $?}.must_equal "0\n"
      end

      FileUtils.rm_f bd
      FileUtils.rm_f "#{bd}.avant"
    end
  end
end
