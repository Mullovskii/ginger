class BotAction < ApplicationRecord
  include Rails.application.routes.url_helpers

  belongs_to :user
  validates_presence_of :user_input, message: "ты хотел что-то сказать"
  validates_length_of :user_input, minimum: 2, maximum: 200, message: "accepts only 2 - 200" 
  before_save :strip_user_input

TRAINING_DATA = YAML.load_file('config/chatbot/training.yml') 
EVENTS_ARRAY = {"events" => ["да", "ок", "давай", "события", "событие", "ивенты", "ивент", "интересное", "семинары", "семинар", "концерты", "концерт", "уроки", "урок", "лекции", "фильмы", "куда"]}


#1
def process_input(user_input)
  user_input_tokens = clean_user_input(user_input)
  common_array = user_input_tokens & EVENTS_ARRAY["events"]  #Intersection of both arrays
  common_word = common_array.present? ? EVENTS_ARRAY.keys[0] : "classification_failed"
  send("#{common_word}_enquiry", user_input_tokens)
end

def classification_failed_enquiry(*args)
    self.update_attribute(:bot_response, error_response)
    return false
end

def self.greeting(id)
  BotAction.create(bot_response: "Привет! Меня зовут Хлои. Я умею находить интересные события рядом. Что тебе интересно?", user_id: id, created_at: Time.now, updated_at: Time.now)
end

#3 nbayes iterates
 def nbayes_classification(user_input_tokens, method_name)
    nbayes = NBayes::Base.new(binarized: true)             #
    TRAINING_DATA[method_name.to_s].each do |key, value|   #getting the inner hash, ex: 'new_laptop_enquiry' hash
      category = key                                       #assigning key as category (class), ex: 'new_laptop_enquiry'
      #puts "\n\nCategory: #{category.inspect}\n\n"
      value.each do |str|
        #puts "\n\nString: #{str.inspect}\n\n"
        nbayes.train(str.split(/\s+/), category)           #Training the nbayes object, with each string under 'new_laptop_enquiry' class
      end
    end
 
    nbayes.assume_uniform = true                           #
    result = nbayes.classify(user_input_tokens)            #classifying the input form user 
    #nbayes.dump('config/rembot/dump.yml')                 #dump of trained data, for us to observe how the classification is done
    result.each do |k, v|
      puts "\n#{(v * 100)} => #{k}\n"                      #display of classified log probabilities for each category
    end
    result.max_class                                       #final classified category, ex: 'new_laptop_enquiry'
end



#classifications related to events
#2 we understand the query is about the event
  def events_enquiry(user_input_tokens)
    send(nbayes_classification(user_input_tokens, __method__))
  end

#4
  def tomorrow_event_enquiry(*args)
    self.update_attribute(:bot_response, "Интересные события на завтра:")
    #some action triggers
    new_polymorphic_path('event')
  end
 
  def event_index_enquiry(*args)
    # self.update_attribute(:bot_response, "Вот все события сегодня в городе:")
    mix = URI.parse("https://api.timepad.ru/v1/events.json").read
    mix = ActiveSupport::JSON.decode(mix)["values"]
    self.update_attribute(:bot_response, mix)
    #some action triggers
    polymorphic_path('events')
  end
 
  def more_event_enquiry(*args)
    laptop_count = Event.all.count
    self.update_attribute(:bot_response, "There are #{event_count} events in total")
    #some action triggers
    return false
  end
 
private

def error_response
    ["Сори, не поняла, бывает.. давай еще разок",
     "Ты по-русски можешь сказать?... не понятно", 
     "Так... давай еще раз, но внятнее..",
     "Перефразируй, братюня..,
     Давай потолкуем.. давай потолкуем.. Короче не поняла я.."].sample
  end
 
def strip_user_input
    self.user_input = self.user_input.squish
end

def clean_user_input(user_input)
    # rm_spl_chars = user_input.downcase.gsub(/[^a-zA-Z0-9-#\s]/, '')
    # rm_spl_chars.split(/\s+/)
    rm_spl_chars = user_input.downcase.split(/[^[:word:]]+/)
end

end