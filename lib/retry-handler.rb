require 'timeout'
require 'logger'

class RetryError < StandardError; end
class RetryOverError < RetryError; end

module RetryHandler
  DEFAULT_MAX_RETRY = 3
  DEFAULT_WAIT_TIME = 1
  INFINITY_EXECUTE = nil

  def self.retry_handler(options={}, &block)
    max = options[:max] || DEFAULT_MAX_RETRY
    wait = options[:wait] || DEFAULT_WAIT_TIME
    timeout = options[:timeout] || INFINITY_EXECUTE
    exception = options[:accept_exception] || RetryError 
    logger = options[:logger] || Logger.new(nil)

    _retry_handler(max, wait, exception, logger) do
      timeout(timeout, exception) do
        block.call
      end
    end
  end

  private
  def self._retry_handler(max_retry, wait_time, accept_exception, logger, &block)
    retry_cnt = 0 

    begin
      block.call
    rescue accept_exception => ex
      logger.error ex

      if retry_cnt >= max_retry
        logger.info "retry over error: #{max_retry}"
        raise RetryOverError.new, ex
      else
        retry_cnt += 1
        logger.info "retry:#{retry_cnt}"
        logger.info "wait #{wait_time} sec"
        sleep wait_time
        retry
      end
    end
  end
end

class Proc
  def retry(options={})
    RetryHandler.retry_handler(options){
      self.call
    }
  end
end

class Method
  def retry(*args)
    options = args.last.is_a?(::Hash) ? args.pop : {}
    RetryHandler.retry_handler(options) do
      self.call(*args)
    end
  end
end

module Kernel
  def retry_handler(options={}, &block)
    block.retry(options) if block_given?
  end
end

