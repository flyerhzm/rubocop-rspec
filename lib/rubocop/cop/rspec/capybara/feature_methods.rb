# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      module Capybara
        # Checks for consistent method usage in feature specs.
        #
        # @example
        #   # bad
        #   feature 'User logs in' do
        #     given(:user) { User.new }
        #
        #     background do
        #       visit new_session_path
        #     end
        #
        #     scenario 'with OAuth' do
        #       # ...
        #     end
        #   end
        #
        #   # good
        #   describe 'User logs in' do
        #     let(:user) { User.new }
        #
        #     before do
        #       visit new_session_path
        #     end
        #
        #     it 'with OAuth' do
        #       # ...
        #     end
        #   end
        class FeatureMethods < Cop
          MSG = 'Use `%<replacement>s` instead of `%<method>s`.'.freeze

          # https://git.io/v7Kwr
          MAP = {
            background: :before,
            scenario:   :it,
            xscenario:  :xit,
            given:      :let,
            given!:     :let!,
            feature:    :describe
          }.freeze

          def_node_matcher :feature_method, <<-PATTERN
            (block
              $(send {(const nil? :RSpec) nil?} ${#{MAP.keys.map(&:inspect).join(' ')}} ...)
            ...)
          PATTERN

          def on_block(node)
            feature_method(node) do |send_node, match|
              add_offense(
                send_node,
                location: :selector,
                message: format(MSG, method: match, replacement: MAP[match])
              )
            end
          end

          def autocorrect(node)
            lambda do |corrector|
              corrector.replace(node.loc.selector, MAP[node.method_name].to_s)
            end
          end
        end
      end
    end
  end
end
