require 'rails_helper'

RSpec.describe Recipe, type: :model do
  subject { Recipe.new(title: 'Test Recipe', cook_time: 15, prep_time: 10, ratings: 4.5)}

  it 'is valid with valid attributes' do
    expect(subject).to be_valid
  end
  it 'is not valid without title' do
    subject.title = nil
    expect(subject).not_to be_valid
  end
  it 'is not valid without cook_time' do
    subject.cook_time = nil
    expect(subject).not_to be_valid
  end
  it 'is not valid with cook time being float' do
    subject.cook_time = 4.5
    expect(subject).not_to be_valid
  end
  it 'is not validd with ratings bigger than 5' do
    subject.ratings = 5.1
    expect(subject).not_to be_valid
  end

end
