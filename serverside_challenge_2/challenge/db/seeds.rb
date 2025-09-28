# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

require 'csv'
csv_dir = Rails.root.join("db", "seeds")

CSV.foreach(csv_dir.join("providers.csv"), headers: true) do |row|
  Provider.create!(
    id: row["id"],
    name: row["name"],
  )
end

CSV.foreach(csv_dir.join("plans.csv"), headers: true) do |row|
  Plan.create!(
    id: row["id"],
    provider_id: row["provider_id"],
    name: row["name"],
  )
end

CSV.foreach(csv_dir.join("basic_fees.csv"), headers: true) do |row|
  BasicFee.create!(
    plan_id: row["plan_id"],
    ampere: row["ampere"],
    fee: row["fee"],
  )
end

CSV.foreach(csv_dir.join("usage_charges.csv"), headers: true) do |row|
  UsageCharge.create!(
    plan_id: row["plan_id"],
    usage_lower: row["usage_lower"],
    usage_upper: row["usage_upper"],
    unit_price: row["unit_price"],
  )
end