module CypressViewportEnvironmentVariables
  class Viewport
    DEVICES = {
      '1920x1080' => 'Microsoft Windows RT Tablet',
      '1280x720' => 'Microsoft Windows RT Tablet',
      '1024x1366' => 'iPad Pro (1st gen 12.9") , iPad Pro (2nd gen 12.9") , iPad Pro (3rd gen 12.9") , iPad Pro (4th gen 12.9")',
      '834x1194' => 'iPad Pro (3rd gen 11") , iPad Pro (4th gen 11")',
      '810x1080' => 'iPad 7th gen',
      '800x1280' => 'Amazon KSFUWI Fire HD 10 (2017), Amazon KFMAWI Fire HD 10 (2019), Samsung SM-T580 Galaxy Tab A 10.1, Samsung SM-T510 Galaxy Tab A 10.1 (2019), Samsung SM-T560NU Galaxy Tab E',
      '768x1024' => 'iPad 1-6, iPad mini, iPad Air 1-2, iPad Pro (1st gen 9.7")',
      '601x962' => 'Amazon KFGIWI Kindle Fire HD 8 2016, Amazon KFDOWI Kindle Fire HD 8 (2017), Amazon KFKAWI Fire HD 8 (2018), Amazon KFKAWI Fire HD 8 (2018)',
      '428x926' => 'iPhone 12 Pro Max',
      '414x896' => 'iPhone XS Max, iPhone XR, iPhone 11, iPhone 11 Pro Max',
      '414x736' => 'iPhone 6 Plus , iPhone 6s Plus , iPhone 7 Plus , iPhone 8 Plus',
      '390x844' => 'iPhone 12 Pro , iPhone 12',
      '375x812' => 'iPhone X , iPhone XS , iPhone 11 Pro',
      '375x667' => 'iPhone SE 2nd gen, iPhone 6 , iPhone 6s , iPhone 7 , iPhone 8',
      '360x780' => 'iPhone 12 mini',
      '360x640' => 'Various Samsung Galaxy, Motorola, Huawei, and other phones',
      '320x568' => 'iPhone 5 , iPhone 5s , iPhone 5c , iPhone SE 1st gen',
      '320x480' => 'iPhone 1st gen , iPhone 3G , iPhone 3GS , iPhone 4',
    }

    attr_reader :viewportPreset

    def initialize(start_date:, end_date:, row:, total_users:)
      number_of_users = row.metrics.first.values.first.to_f
      device, resolution = row.dimensions[0], row.dimensions[1]

      @list = "VA Top #{device.capitalize} Viewports"
      @rank = nil
      @devicesWithViewport = device_list(device: device, resolution: resolution)
      @percentTraffic = "#{calculate_percentage_of_users_who_use_viewport(number_of_users, total_users)}%"
      @percentTrafficPeriod = "from #{start_date} to #{end_date}"
      @viewportPreset = "va-top-#{device}-"
      @width, @height = resolution.split('x')
    end

    def update_attributes_that_reference_rank(rank)
      update_rank(rank)
      update_viewport_preset(rank)
    end

    private

    attr_writer :rank, :viewportPreset

    def device_list(device:, resolution:)
      return 'This property is not set for desktops.' if device == 'desktop'

      DEVICES[resolution] || 'This viewport is missing from the devices lookup table. Please contact the Testing Tools Team to have it added.'
    end

    def calculate_percentage_of_users_who_use_viewport(number_of_users, total_users)
      (number_of_users / total_users * 100).round(2)
    end

    def update_rank(rank)
      self.rank = rank
    end

    def update_viewport_preset(rank)
      self.viewportPreset += rank
    end
  end
end