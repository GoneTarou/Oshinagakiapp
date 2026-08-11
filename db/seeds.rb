# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
comic_market = Event.find_or_create_by!(name: "コミックマーケット")
EventOccurrence.find_or_create_by!(event: comic_market, number: 108)
EventOccurrence.find_or_create_by!(event: comic_market, number: 109)

comitia = Event.find_or_create_by!(name: "COMITIA")
EventOccurrence.find_or_create_by!(event: comitia, number: 157)
EventOccurrence.find_or_create_by!(event: comitia, number: 158)
EventOccurrence.find_or_create_by!(event: comitia, number: 159)

Event.find_or_create_by!(name: "その他")
