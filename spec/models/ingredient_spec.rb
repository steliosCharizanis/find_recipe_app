require 'rails_helper'

RSpec.describe Ingredient, type: :model do

  subject { Ingredient.new(name: 'Ingredient test')}

  it 'is valid with valid attributes' do
    expect(subject).to be_valid
  end
	it 'is valid if name is unique' do
    subject.name = 'Ingredient test 1'
    expect(subject).to be_valid
  end
  it 'is not valid if name is not unique' do
		ingredient = Ingredient.create(name: 'Ingredient test')
    expect(subject).not_to be_valid
  end
  it 'is basic ingredient true' do
    ingredient = Ingredient.create(name: 'water cup')

    expect(ingredient.is_basic_ingredient).to equal(true)
  end

end
