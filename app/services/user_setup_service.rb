class UserSetupService
  def initialize(user)
    @user = user
  end

  def setup_initial_data
    setup_units
    setup_general_configurations
  end

  private

  def setup_units
    # Only create if this user has no units
    return if @user.units.exists?

    [
      '%',
      'aplicación',
      'pieza',
      'cms',
      'mt2',
      'pliego',
      'mts',
      'producto'
    ].each do |description|
      @user.units.create!(description: description)
    end
  end

  def setup_general_configurations
    return if @user.general_configurations.exists?

    [
      {
        description: 'margen',
        amount: 25.0,
        unit: @user.units.find_by(description: '%')
      },
      {
        description: 'merma',
        amount: 5.0,
        unit: @user.units.find_by(description: '%')
      },
      {
        description: 'Margen ancho',
        amount: 2.0,
        unit: @user.units.find_by(description: 'cms')
      },
      {
        description: 'Margen largo',
        amount: 2.0,
        unit: @user.units.find_by(description: 'cms')
      }
    ].each do |config|
      @user.general_configurations.create!(config)
    end
  end
end 