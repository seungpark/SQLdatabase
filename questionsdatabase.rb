require 'singleton'
require 'sqlite3'

class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')

    self.results_as_hash = true
    self.type_translation = true
  end

end #end of class


class Questions

  def self.find_by_id(id)
    results = QuestionsDatabase.instance.execute("SELECT * FROM questions WHERE id = #{id}")
    results.map { |result| Questions.new(result) }
  end

  attr_accessor :id, :title, :body, :author_id

  def initialize(options = {})
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @author_id = options['author_id']
  end

end


class Users

  def self.find_by_id(id)
    results = QuestionsDatabase.instance.execute("SELECT * FROM users WHERE id = #{id}")
    results.map { |result| Users.new(result) }
  end

  attr_accessor :id, :fname, :lname

  def initialize(options = {})
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

end


class Replies

  def self.find_by_id(id)
    results = QuestionsDatabase.instance.execute("SELECT * FROM replies WHERE id = #{id}")
    results.map { |result| Replies.new(result) }
  end

  attr_accessor :id, :body, :question_id, :parent_reply_id, :reply_author_id

  def initialize(options = {})
    @id = options['id']
    @body = options['body']
    @question_id = options['question_id']
    @parent_reply_id = options['parent_reply_id']
    @reply_author_id = options['reply_author_id']
  end

end

class QuestionFollows

  def self.followers_for_question_id(question_id)
    results = QuestionsDatabase.instance.execute(
    "SELECT * FROM question_follows WHERE question_id = #{question_id}"
    )
    results.map { |result| QuestionFollows.new(result) }
  end

  def self.followed_questions_for_user_id(follower_id)
    results = QuestionsDatabase.instance.execute(
    "SELECT * FROM question_follows WHERE follower_id = #{follower_id}"
    )
    results.map { |result| QuestionFollows.new(result) }
  end

  attr_accessor :follower_id, :question_id

  def initialize(options = {})
    @follower_id = options['follower_id']
    @question_id = options['question_id']
  end

end


class QuestionLikes

  def self.likers_for_question_id(question_id)
    results = QuestionsDatabase.instance.execute(
    "SELECT * FROM question_likes WHERE question_id = #{question_id}"
    )
    results.map { |result| QuestionLikes.new(result) }
  end

  def self.liked_questions_for_user_id(user_id)
    results = QuestionsDatabase.instance.execute(
    "SELECT * FROM question_likes WHERE user_id = #{user_id}"
    )
    results.map { |result| QuestionLikes.new(result) }
  end

  attr_accessor :user_id, :question_id

  def initialize(options = {})
    @user_id = options['user_id']
    @question_id = options['question_id']
  end

end
