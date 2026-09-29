# ---------- Estágio 1: instala as dependências ----------
FROM node:22-alpine AS deps

WORKDIR /app

# Copia só os manifestos primeiro para aproveitar o cache de camadas:
# se o código mudar mas as dependências não, esta etapa não roda de novo.
COPY package.json package-lock.json ./

# npm ci instala exatamente o que está no package-lock (build reprodutível);
# --omit=dev deixa de fora dependências de desenvolvimento.
RUN npm ci --omit=dev

# ---------- Estágio 2: imagem final (só o necessário para rodar) ----------
FROM node:22-alpine

ENV NODE_ENV=production

WORKDIR /app

# Traz apenas o node_modules pronto do estágio anterior (sem cache do npm)
COPY --from=deps /app/node_modules ./node_modules
COPY package.json ./
COPY src ./src

# Usuário sem privilégios de root (já existe na imagem oficial do Node)
USER node

EXPOSE 3000

# O Docker marca o container como unhealthy se a API ou o banco pararem de responder
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
  CMD wget -qO- http://localhost:3000/health || exit 1

CMD ["node", "src/server.js"]
