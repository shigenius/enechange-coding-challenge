class CreateBasicFees < ActiveRecord::Migration[7.0]
  def change
    create_table :basic_fees, comment: '基本料金' do |t|
      t.references :plan, null: false, foreign_key: true
      t.integer :ampere, null: false, comment: "契約アンペア数(A)"
      t.decimal :fee, precision: 10, scale: 2, null: false, comment: "基本料金(円)"
      t.timestamps
    end

    add_index :basic_fees, [:plan_id, :ampere], unique: true
    add_index :basic_fees, :ampere
  end
end
