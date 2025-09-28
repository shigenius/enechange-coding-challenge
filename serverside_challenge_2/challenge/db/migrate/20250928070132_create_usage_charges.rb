class CreateUsageCharges < ActiveRecord::Migration[7.0]
  def change
    create_table :usage_charges do |t|
      t.references :plan, null: false, foreign_key: true
      t.integer :usage_lower, null: false, comment: "電気使用量(kWh) 下限"
      t.integer :usage_upper, comment: "電気使用量(kWh) 上限"
      t.decimal :unit_price, precision: 10, scale: 2, null: false, comment: "従量料金単価(円/kWh)"
      t.timestamps
    end

    add_index :usage_charges, [:usage_lower, :usage_upper]
  end
end
