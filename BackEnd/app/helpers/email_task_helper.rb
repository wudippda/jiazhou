module EmailTaskHelper

  TASK_PARAMS_TAG = 'task_params'
  @@email_task_types = nil
  EMAIL_TASK_TYPE_FILE_PATH = Rails.root.join('config', 'email_task_types.yml')

  def self.getTaskTypes
    @@email_task_types ||= YAML.load_file(EMAIL_TASK_TYPE_FILE_PATH)
  end

  def self.validateTaskTypeId(taskTypeId)
    return !getTaskTypes[taskTypeId - 1].nil?
  end

  def self.validateTaskParams(taskTypeId, taskParams)
    if validateTaskTypeId(taskTypeId)
      loadedTaskParams = getTaskTypes[taskTypeId - 1][TASK_PARAMS_TAG]
      return true if loadedTaskParams.nil? || (!taskParams.keys.nil? && (loadedTaskParams.collect{ |e| e['name'].to_sym } - taskParams.keys).empty?)
    end
    return false
  end

end