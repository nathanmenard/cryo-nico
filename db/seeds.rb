franchise = Franchise.create!(name: 'Reims', email: 'contact@cryotera.fr', address: '2 rue Jules Méline', zip_code: '51430', city: 'Bezannes', phone: '0326779750', siret: '81501516900015', tax_id: 'FR81815015169')

user = User.create!(franchise_id: franchise.id, email: 'contact@drakkr.com', password: 'secret', first_name: 'Nathan', last_name: 'Menard', superuser: true)
client = Client.create!(franchise_id: franchise.id, first_name: 'John', last_name: 'Doe', email: 'client@gmail.com', password: 'client', birth_date: '01/01/1990', male: true)

company = Company.create!(franchise_id: franchise.id, name: 'Apple', email: 'contact@apple.com', phone: '0620853909', address: '60 rue des Gobelins', zip_code: 51100, city: 'Reims', siret: '81214811200012')
#company_client = CompanyClient.create!(company_id: company.id, email: 'mimouni.fouzia@gmail.com', password: 'said', first_name: 'Fouzia', last_name: 'Mimouni')

room = Room.create!(franchise_id: franchise.id, name: 'Salle de Cryothérapie', capacity: 2)

descriptions = {
  'Cryo Localisée' => 'La cryothérapie localisée consiste à exposer une partie du corps à de l’air froid pulsé à -150 degrés. De par ses vertus anti-inflammatoire, antalgique et anti-âge, elle permet la diminution des douleurs localisées ainsi que la prévention du vieillissement cutané.',
  'Cryothérapie Corps Entier' => 'La chambre de cryothérapie corps entier est un outil utilisant le froid à des fins thérapeutiques. Le procédé est fondé sur des séries d’expositions du corps entier à basses températures (entre -85°C et -110°C) sur une période de 3 à 4 minutes. L’exposition à ces températures permet à l’individu de mettre en place des réflexes de protection contre le froid et de développer des effets bénéfiques durables.',
  'Cryolipolise' => 'Le terme cryolipolyse signifie littéralement “destruction des graisses par le froid“. Il s’agit d’un traitement efficace et non invasif permettant d’éliminer les amas graisseux de manière définitive et indolore.',
  'Pressothérapie' => 'La pressothérapie est une méthode thérapeutique provoquant l’activation de la circulation veineuse et lymphatique par un système de compression et de décompression des pneumatiques.',
  'Nutrition' => 'Avoir une alimentation saine, équilibrée et adaptée est un véritable pilier de la santé. Nos partenaires en micronutrition accompagnent nos clients dans l’élaboration de protocoles nutritionnels sur-mesure en fonction de leurs besoins.'
}

['Cryo Localisée', 'Cryothérapie Corps Entier', 'Cryolipolise', 'Pressothérapie', 'Nutrition'].each do |product_name|
  description = descriptions[product_name]
  product = Product.create!(room_id: room.id, name: product_name, description: description, duration: 30, franchise: franchise)
  ProductPrice.create!(product_id: product.id, session_count: 1, total: 45, professionnal: false)
  ProductPrice.create!(product_id: product.id, session_count: 1, total: 35, professionnal: false, first_time: true)
  ProductPrice.create!(product_id: product.id, session_count: 5, total: 195, professionnal: false)
  ProductPrice.create!(product_id: product.id, session_count: 10, total: 350, professionnal: false)
  ProductPrice.create!(product_id: product.id, session_count: 10, total: 300, professionnal: true)
  ProductPrice.create!(product_id: product.id, session_count: 20, total: 500, professionnal: true)
end
