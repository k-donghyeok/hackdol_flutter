from flask import Flask, request, jsonify
from some_chatbot_library import get_chatbot_response

app = Flask(__name__)

@app.route('/chatbot', methods=['POST'])
def chatbot():
    data = request.get_json()
    question = data['question']
    response = get_chatbot_response(question)  # 이 함수는 실제 챗봇 로직을 수행합니다.
    return jsonify({'response': response})

if __name__ == '__main__':
    app.run(host='192.168.35.3', port=5000)
