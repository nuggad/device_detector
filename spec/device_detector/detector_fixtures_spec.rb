require_relative '../spec_helper'

describe DeviceDetector do

  fixture_dir = File.expand_path('../../fixtures/detector', __FILE__)
  fixture_files = Dir["#{fixture_dir}/*.yml"]
  fixture_files.each do |fixture_file|

    describe File.basename(fixture_file) do

      fixtures = nil
      begin
        fixtures = YAML.load(File.read(fixture_file))
      rescue Psych::SyntaxError => e
        fail "Failed to parse #{fixture_file}, reason: #{e}"
      end

      fixtures.each do |f|

        user_agent = f["user_agent"]
        detector = DeviceDetector.new(user_agent)
        os = detector.send(:os)

        describe user_agent do
          it "should be detected" do
            if detector.bot?
              assert_equal f["bot"]["name"], detector.bot_name, "failed bot name detection"
            else
              if f["client"]
                assert_equal f["client"]["name"], detector.name, "failed client name detection"
              end
              if f["os_family"] != "Unknown"
                assert_equal f["os_family"], os.family, "failed os family detection"
                assert_equal f["os"]["name"], os.name, "failed os name detection"
                assert_equal f["os"]["short_name"], os.short_name, "failed os short name detection"
                if f["os"]["version"].nil?
                  assert_nil os.full_version, "failed os version detection"
                else
                  assert_equal f["os"]["version"], os.full_version, "failed os version detection"
                end
              end
              if f["device"]
                expected_type = f["device"]["type"]
                actual_type = detector.device_type
                if expected_type.nil?
                  assert_nil actual_type, "failed device type detection"
                else
                  assert_equal expected_type, actual_type, "failed device type detection"
                end
                model = f["device"]["model"]
                if model.nil?
                  assert_nil detector.device_name, "failed device name detection"
                else
                  assert_equal model.to_s, detector.device_name, "failed device name detection"
                end
              end
            end
          end
        end
      end

    end

  end

end
