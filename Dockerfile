# Node 20-alpine para backend leve e seguro
FROM node:20-alpine

WORKDIR /app

# Copiar apenas arquivos de dependência primeiro para aproveitar cache do Docker
COPY package*.json ./
RUN npm install

# Copiar todo o resto dos arquivos do backend
COPY . .

# Rodar o build para converter o TypeScript para JavaScript (dist/)
RUN npm run build

# Definir como o servidor será executado em produção
EXPOSE 3000
CMD ["node", "dist/index.js"]
