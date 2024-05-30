from flask import Flask, request, jsonify
from transformers import PreTrainedTokenizerFast, GPT2LMHeadModel

# KoGPT2 모델과 토크나이저 로드
tokenizer = PreTrainedTokenizerFast.from_pretrained("skt/kogpt2-base-v2", bos_token='</s>', eos_token='</s>', unk_token='<unk>', pad_token='<pad>', mask_token='<mask>')
model = GPT2LMHeadModel.from_pretrained("skt/kogpt2-base-v2")

app = Flask(__name__)

def generate_response(input_text):
    # 입력 문장 토큰화
    inputs = tokenizer.encode(input_text, return_tensors="pt")
    
    # 응답 생성
    reply_ids = model.generate(inputs, max_length=50, num_return_sequences=1, pad_token_id=tokenizer.pad_token_id)
    
    # 응답 디코딩
    response = tokenizer.decode(reply_ids[0], skip_special_tokens=True)
    return response

@app.route('/chat', methods=['POST'])
def chat():
    user_input = request.json.get('message')
    response = generate_response(user_input)
    return jsonify({'response': response})

if __name__ == '__main__':
    app.run(host='192.168.35.62', port=5005)
