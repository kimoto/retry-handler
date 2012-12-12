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
