require_relative 'test_helper'

describe "GestionAcademique" do
  describe "trouver" do
    it_ "signale une erreur lorsque le fichier est inexistant", :intermediaire do
      FileUtils.rm_f '.cours.txt'
      genere_erreur( /fichier.*[.]cours.txt.*existe pas/ ) do
        ga( 'trouver' )
      end
    end

    it_ "retourne rien lorsque fichier vide" do
      avec_fichier '.cours.txt' do
        execute_sans_sortie_ou_erreur do
          ga( 'trouver .' )
        end
      end
    end

    it_ "signale une erreur lorsqu'argument en trop", :intermediaire do
      avec_fichier '.cours.txt' do
        genere_sortie_et_erreur( [], /Argument.*en trop/ ) do
          ga( 'trouver "." foo' )
        end
      end
    end

    context "banque de cours avec plusieurs cours" do
      let(:lignes) { IO.readlines("Tests/cours.txt.5+1") }
      let(:attendu) { ['INF1120 "Programmation I" ()',
                       'INF1130 "Mathematiques pour informaticien" ()',
                       'INF2120 "Programmation II" (INF1120)',
                       'INF3105 "Structures de donnees et algorithmes" (INF1130:INF2120)',
                       'INF3135 "Construction et maintenance de logiciels" (INF1120)'] }


      it_ "trouve toutes les lignes avec un caractere quelconque" do
        avec_fichier '.cours.txt', lignes do
          genere_sortie( attendu ) do
            ga( 'trouver .' )
          end
        end
      end

      it_ "trouve toutes les lignes avec n'importe quoi" do
        avec_fichier '.cours.txt', lignes do
          genere_sortie( attendu ) do
            ga( "trouver '.*'" )
          end
        end
      end

      it_ "trouve les lignes matchant une chaine specifique mais parmi les actifs seulement" do
        avec_fichier '.cours.txt', lignes do
          attendu = ['INF1120 "Programmation I" ()',
                     'INF1130 "Mathematiques pour informaticien" ()',
                     'INF2120 "Programmation II" (INF1120)']

          genere_sortie( attendu ) do
            ga( 'trouver mat' )
          end
        end
      end

      it_ "trouve les lignes matchant une chaine specifique parmi toutes y compris les inactifs", :intermediaire do
        avec_fichier '.cours.txt', lignes do
          attendu = ['INF1120 "Programmation I" ()',
                     'INF1130 "Mathematiques pour informaticien" ()',
                     'INF2120 "Programmation II" (INF1120)',
                     'MAT3140? "Algebre et logique" ()',
                    ]

          genere_sortie( attendu ) do
            ga( 'trouver --avec_inactifs MAT' )
          end
        end
      end

      it_ "trouve les lignes matchant une chaine specifique parmi toutes y compris les inactifs en ordre de sigle", :intermediaire do
        avec_fichier '.cours.txt', lignes do
          attendu = ['INF1120 "Programmation I" ()',
                     'INF1130 "Mathematiques pour informaticien" ()',
                     'INF2120 "Programmation II" (INF1120)',
                     'MAT3140? "Algebre et logique" ()',
                    ]
          genere_sortie( attendu ) do
            ga( 'trouver --avec_inactifs --cle_tri=sigle MAT' )
          end
        end
      end

      it_ "trouve les lignes matchant une chaine specifique parmi toutes y compris les inactifs en ordre de titre", :intermediaire do
        avec_fichier '.cours.txt', lignes do
          attendu = ['MAT3140? "Algebre et logique" ()',
                     'INF1130 "Mathematiques pour informaticien" ()',
                     'INF1120 "Programmation I" ()',
                     'INF2120 "Programmation II" (INF1120)']


          genere_sortie( attendu ) do
            ga( 'trouver --avec_inactifs --cle_tri=titre MAT' )
          end
        end
      end

     it_ "affiche tous les cours selon le format indique", :intermediaire do
        avec_fichier '.cours.txt', lignes do
          attendu = ["INF1120 => 'Programmation I' (3 cr.)",
                     "INF1130 => 'Mathematiques pour informaticien' (3 cr.)",
                     "INF2120 => 'Programmation II' (3 cr.)",
                     "INF3105 => 'Structures de donnees et algorithmes' (3 cr.)",
                     "INF3135 => 'Construction et maintenance de logiciels' (3 cr.)",
                    ]

          genere_sortie( attendu ) do
            ga( "trouver --format=\"%S => '%T' (%C cr.)\" '.'" )
          end
        end
      end
    end
  end
end
