class GetRegistration
  include Sidekiq::Worker
  def perform(number)
    response = check_number(number)
    Lookup.new({
      number: number,
      response: response
    }).save!
    sleep(1)
    self.perform_in(60*60*24*28, number)
  end

  def check_number(number)
    content = Nokogiri.parse(`curl 'https://registry.faa.gov/aircraftinquiry/Search/NNumberResult' \
      -H 'Connection: keep-alive' \
      -H 'Cache-Control: max-age=0' \
      -H 'Origin: https://registry.faa.gov' \
      -H 'Upgrade-Insecure-Requests: 1' \
      -H 'DNT: 1' \
      -H 'Content-Type: application/x-www-form-urlencoded' \
      -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.141 Safari/537.36' \
      -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9' \
      -H 'Sec-Fetch-Site: same-origin' \
      -H 'Sec-Fetch-Mode: navigate' \
      -H 'Sec-Fetch-User: ?1' \
      -H 'Sec-Fetch-Dest: document' \
      -H 'Accept-Language: en-US,en;q=0.9' \
      --data-raw 'NNumbertxt=N#{number}' \
      --compressed`);false
    content.search("table td").collect{|x| [x.attributes["data-label"].value, x.text.strip]}.reject{|x| x[0].empty?}
  end

  def self.kickoff
    chars = "A".upto("Z").to_a|(0.upto(9).collect(&:to_s))
    letters = []
    chars.each do |char|
      letters << char
      chars.each do |other_char|
        letters << char+other_char
      end
    end;false
    all_n_numbers = []
    1.upto(9999).each do |number|
      if number > 99
        letters.each do |l|
          all_n_numbers << "#{number}#{l}" if "#{number}#{l}".length < 6
        end
        all_n_numbers << "#{number}"
      end
    end;false
    all_n_numbers.shuffle.collect{|x| GetRegistration.perform_async(x)}
  end
end