require File.dirname(__FILE__) + '/spec_helper'

describe RetryHandler do
  let(:retry_count)  { 5 }
  let(:wait) { 0.1 }
  let(:exception) { StandardError }

  describe '.retry_handler' do
    it 'calls and retries given block' do
      proc = Proc.new { }
      proc.should_receive(:call).exactly(1 + retry_count).times.and_raise(exception)

      expect {
        RetryHandler.retry_handler({max: retry_count, wait: wait, accept_exception: exception}, &proc)
      }.to raise_error(exception)
    end

    context 'given block takes argument' do
      it 'passes retry count to given block' do
        proc = Proc.new { }
        proc.should_receive(:call).with do |retry_cnt|
          retry_cnt.should be_a(Fixnum)
        end

        RetryHandler.retry_handler({max: retry_count, wait: wait, accept_exception: exception}, &proc)
      end
    end
  end
end

describe Method do
  let(:retry_count)  { 5 }
  let(:wait) { 0.1 }
  let(:exception) { StandardError }

  describe '#retry' do
    context 'arity is 0' do
      it 'does not pass retry count to given block' do
        klass = Class.new do
          define_method(:retriable) do
            raise StandardError
          end
        end

        method = klass.new.method(:retriable)
        method.should_receive(:call).with(no_args())

        method.retry(accept_exception: exception)
      end
    end

    context 'arity larger than 0' do
      it 'passes retry count to given block' do
        klass = Class.new do
          define_method(:retriable) do |retry_cnt, _|
            raise StandardError
          end
        end

        method = klass.new.method(:retriable)
        method.should_receive(:call).with do |retry_cnt|
          retry_cnt.should be_a(Fixnum)
        end

        method.retry(accept_exception: exception)
      end
    end
  end
end
