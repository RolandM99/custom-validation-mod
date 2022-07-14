module Validation
  def self.included(test)
    test.extend(CustomValidation)
  end

  module CustomValidation
    # rubocop:disable Style/ClassVars
    @@rule_types = %i[presence format type]
    @@exception_messages = {
      # initialization of class variables
      presence: 'attribute should be neither nil nor an empty string',
      format: 'attribute should match the passed regular expression',
      type: 'attribute should be an instance of the passed class'
    }
    # rubocop:enable Style/ClassVars

    def r_name
      "@@#{to_s.downcase}rules"
    end

    # list of all validation rules for the current class

    # rubocop:disable Style/EvalWithLocation
    def rules
      eval("#{r_name}rules ||= {}") # rubocop:disable Security/Eval
    end
    # rubocop:enable Style/EvalWithLocation

    def error_messages
      @@exception_messages
    end

    # action to add new rule on the validation list
    # rubocop:disable Style/GuardClause
    def validate(name, rule)
      if @@rule_types.include?(rule.keys.first)
        rules[name] = rule
      else
        raise "Validation#syntax_error: unsupported validation rule key \\ \"#{rule.keys.first}\" \\. "
      end
    end
    # rubocop:enable Style/GuardClause
  end

  def valid?
    self.class.rules.each do |key, val|
      return false unless custom_validate_attribute key, val
    end
    true
  end

  def validate!
    self.class.rules.each do |key, val|
      custom_validate_attribute key, val, true
    end
    true
  end

  private

  def presence?(name, _rule)
    point = send(name)
    !point.nil? && !(point.is_a?(String) && point.empty?)
  end

  def format?(name, format)
    point = send(name)
    point =~ format
  end

  def type?(name, type)
    point = send(name)
    point.is_a? type
  end

  def raise_error(key, rule_name, rule_value)
    raise handling_exception_message(key, rule_name, rule_value)
  end

  def handling_exception_message(key, rule_name, rule_value)
    first_message = "Validation Failed for \"#{key}\":"
    value = "\\\"#{send(key)}\"\\"
    error_text = self.class.error_messages[rule_name].to_s
    body = "#{value} #{error_text}"
    last_message = rule_value == true ? '' : rule_value

    "#{first_message} #{body} #{last_message}."
  end

  # rubocop:disable Style/OptionalBooleanParameter
  def custom_validate_attribute(key, rules, attr = false)
    rules.each_pair do |rule_name, rule_value|
      check = send("#{rule_name}?", key, rule_value)
      raise_error(key, rule_name, rule_value) if attr && !check
      return false unless check
    end
    true
  end
  # rubocop:enable Style/OptionalBooleanParameter
end
